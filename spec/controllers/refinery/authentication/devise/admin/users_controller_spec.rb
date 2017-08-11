require "spec_helper"

describe Refinery::Authentication::Devise::Admin::UsersController, :type => :controller do
  refinery_login_with_devise [:refinery, :superuser]

  shared_examples_for "new, create, update, edit and update actions" do
    it "loads roles" do
      get :new
    end

    it "loads plugins" do
      user_plugin = Refinery::Plugins.registered.detect { |plugin| plugin.name == "refinery_authentication_devise" }
      plugins = Refinery::Plugins.new
      plugins << user_plugin
      expect(plugins).to receive(:in_menu).once{ [user_plugin] }

      expect(Refinery::Plugins).to receive(:registered).at_least(1).times{ plugins }
      get :new
    end
  end

  describe "#new" do
    it "renders the new template" do
      get :new
      expect(response).to be_success
      expect(response).to render_template("refinery/authentication/devise/admin/users/new")
    end

    it_should_behave_like "new, create, update, edit and update actions"
  end

  describe "#create" do
    it "creates a new user with valid params" do
      user = Refinery::Authentication::Devise::User.new :username => "bob"
      expect(user).to receive(:save).once{ true }
      expect(Refinery::Authentication::Devise::User).to receive(:new).once.with(instance_of(ActionController::Parameters)){ user }
      post :create, params: { user: { username: 'bobby' } }
      expect(response).to be_redirect
    end

    it_should_behave_like "new, create, update, edit and update actions"

    it "re-renders #new if there are errors" do
      user = Refinery::Authentication::Devise::User.new :username => "bob"
      expect(user).to receive(:save).once{ false }
      expect(Refinery::Authentication::Devise::User).to receive(:new).once.with(instance_of(ActionController::Parameters)){ user }
      post :create, params: { user: { username: 'bobby' } }
      expect(response).to be_success
      expect(response).to render_template("refinery/authentication/devise/admin/users/new")
    end
  end

  describe "#edit" do
    refinery_login_with_devise [:refinery, :superuser]

    it "renders the edit template" do
      get :edit, params: { id: logged_in_user.id }
      expect(response).to be_success
      expect(response).to render_template("refinery/authentication/devise/admin/users/edit")
    end

    it_should_behave_like "new, create, update, edit and update actions"
  end

  describe "#update" do
    refinery_login_with_devise [:refinery, :superuser]

    let(:additional_user) { FactoryGirl.create :authentication_devise_refinery_user }
    it "updates a user" do
      patch :update, params: { id: additional_user.id.to_s, user: { username: 'bobby' } }
      expect(response).to be_redirect
    end

    context "when specifying plugins" do
      it "won't allow to remove 'Users' plugin from self" do
        patch :update, params: { id: logged_in_user.id.to_s, user: { plugins: ["some plugin"] } }

        expect(flash[:error]).to eq("You cannot remove the 'Users' plugin from the currently logged in account.")
      end

      it "will update to the plugins supplied" do
        expect(logged_in_user).to receive(:update_attributes).with({"plugins" => %w(refinery_authentication_devise some_plugin)})
        allow(Refinery::Authentication::Devise::User).to receive_message_chain(:includes, :find) { logged_in_user }
        patch :update, params: { id: logged_in_user.id.to_s, user: { plugins: %w(refinery_authentication_devise some_plugin) } }
      end
    end

    it_should_behave_like "new, create, update, edit and update actions"
  end
end
