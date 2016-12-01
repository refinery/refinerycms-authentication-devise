require 'spec_helper'

module Refinery
  module Authentication
    module Devise
      describe User, :type => :model do

        let(:user) { FactoryGirl.create(:authentication_devise_user) }
        let(:refinery_user) {
          FactoryGirl.create(:authentication_devise_refinery_user)
        }

        context "Roles" do
          context "add_role" do
            it "raises Exception when Role object is passed" do
              expect {user.add_role(Refinery::Authentication::Devise::Role.new)}.to raise_exception(::ArgumentError)
            end

            it "adds a Role to the User when role not yet assigned to User" do
              expect(proc {
                user.add_role(:new_role)
              }).to change(user.roles, :count).by(1)
              expect(user.roles.collect(&:title)).to include("NewRole")
            end

            it "does not add a Role to the User when this Role is already assigned to User" do
              expect(proc {
                refinery_user.add_role(:refinery)
              }).not_to change(refinery_user.roles, :count)
              expect(refinery_user.roles.collect(&:title)).to include("Refinery")
            end
          end

          context "has_role" do
            it "raises Exception when Role object is passed" do
              expect{ user.has_role?(Refinery::Authentication::Devise::Role.new)}.to raise_exception(::ArgumentError)
            end

            it "returns the true if user has Role" do
              expect(refinery_user.has_role?(:refinery)).to be_truthy
            end

            it "returns false if user hasn't the Role" do
              expect(refinery_user.has_role?(:refinery_fail)).to be_falsey
            end
          end

          describe "role association" do
            it "have a roles attribute" do
              expect(user).to respond_to(:roles)
            end
          end
        end

        context "validations" do
          # email and password validations are done by including devises validatable
          # module so those validations are not tested here
          let(:attributes) do
            {
              :username => "Refinery CMS",
              :email => "refinery@cms.com",
              :password => "123456",
              :password_confirmation => "123456"
            }
          end

          it "requires username" do
            expect(User.new(attributes.merge(:username => ""))).not_to be_valid
          end

          it "rejects duplicate usernames" do
            User.create!(attributes)
            expect(User.new(attributes.merge(:email => "another@email.com"))).not_to be_valid
          end

          it "rejects duplicate usernames regardless of case" do
            User.create!(attributes)
            expect(User.new(attributes.merge(
              :username => attributes[:username].upcase,
              :email => "another@email.com")
            )).not_to be_valid
          end

          it "rejects duplicate usernames regardless of whitespace" do
            User.create!(attributes)
            new_user = User.new(attributes.merge(:username => " Refinery   CMS "))
            new_user.valid?
            expect(new_user.username).to eq('refinery cms')
            expect(new_user).not_to be_valid
          end
        end

        describe ".find_for_database_authentication" do
          it "finds user either by username or email" do
            expect(User.find_for_database_authentication(:login => user.username)).to eq(user)
            expect(User.find_for_database_authentication(:login => user.email)).to eq(user)
          end
        end

        describe "#can_delete?" do
          let(:user_not_persisted) { FactoryGirl.build(:authentication_devise_refinery_user) }
          let(:super_user) do
            FactoryGirl.create(:authentication_devise_refinery_user).tap do |user|
              user.add_role(:superuser)
            end
          end

          context "won't allow to delete" do
            it "not persisted user record" do
              expect(refinery_user.can_delete?(user_not_persisted)).to be_falsey
            end

            it "user with superuser role" do
              expect(refinery_user.can_delete?(super_user)).to be_falsey
            end

            it "if user count with refinery role < 1" do
              ::Refinery::Authentication::Devise::Role[:refinery].users.delete([ refinery_user, super_user ])
              expect(super_user.can_delete?(refinery_user)).to be_falsey
            end

            it "user himself" do
              expect(refinery_user.can_delete?(refinery_user)).to be_falsey
            end
          end

          context "allow to delete" do
            it "if user count with refinery role = 1" do
              ::Refinery::Authentication::Devise::Role[:refinery].users.delete(refinery_user)
              expect(super_user.can_delete?(refinery_user)).to be_truthy
            end

            it "if all conditions return true" do
              expect(super_user.can_delete?(refinery_user)).to be_truthy
            end
          end
        end

        describe "#can_edit?" do
          let(:user_not_persisted) { FactoryGirl.build(:authentication_devise_refinery_user) }
          let(:super_user) do
            FactoryGirl.create(:authentication_devise_refinery_user).tap do |user|
              user.add_role(:superuser)
            end
          end
          let(:user_persisted) { FactoryGirl.create(:authentication_devise_refinery_user)}

          context "won't allow to edit" do
            it "non-persisted user record" do
              expect(refinery_user.can_edit?(user_not_persisted)).to be_falsey
            end

            it "user is not a super user" do
              expect(refinery_user.can_edit?(user_persisted)).to be_falsey
            end
          end

          context "allows to edit" do
            it "when I am a user super" do
              expect(super_user.can_edit?(user_persisted)).to be_truthy
            end

            it "if all conditions return true" do
              expect(super_user.can_edit?(refinery_user)).to be_truthy
            end
          end
        end

        describe "#plugins=" do
          context "when user is not persisted" do
            it "does not add plugins for this user" do
              new_user = FactoryGirl.build(:authentication_devise_user)
              new_user.plugins = ["test"]
              expect(new_user.plugins).to be_empty
            end
          end

          context "when user is persisted" do
            it "only assigns plugins with names that are of string type" do
              user.plugins = [1, :test, false, "refinery_one"]
              expect(user.plugins.collect(&:name)).to eq(["refinery_one"])
            end

            it "won't raise exception if plugins position is not a number" do
              Refinery::Authentication::Devise::UserPlugin.create! :name => "refinery_one", :user_id => user.id

              expect { user.plugins = ["refinery_one", "refinery_two"] }.to_not raise_error
            end

            context "when no plugins assigned" do
              it "assigns them to user" do
                expect(user.plugins).to eq([])

                plugin_list = ["refinery_one", "refinery_two", "refinery_three"]
                user.plugins = plugin_list
                expect(user.plugins.collect(&:name)).to eq(plugin_list)
              end

              it "assigns them to user with unique positions" do
                expect(user.plugins).to eq([])

                plugin_list = ["refinery_one", "refinery_two", "refinery_three"]
                user.plugins = plugin_list
                expect(user.plugins.pluck(:position)).to match_array([1,2,3])
              end
            end

            context "when plugins are already assigned" do
              it "only adds new ones and deletes ones that are not used" do
                user.plugins = ["refinery_one", "refinery_two", "refinery_three"]
                new_plugin_list = ["refinery_one", "refinery_two", "refinery_four"]

                user.plugins = new_plugin_list
                user.plugins.reload
                expect(user.plugins.collect(&:name)).to eq(new_plugin_list)
              end
            end
          end
        end

        describe "#has_plugin?" do
          before do
            allow(user).to receive(:active_plugins).and_return(
              OpenStruct.new(names: %w[koru haka])
            )
          end

          it "is true when the user has an active plugin of the same name" do
            expect(user.has_plugin?("koru")).to be_truthy
          end

          it "is false when the user doesn't have an active plugin of the same name" do
            expect(user.has_plugin?("waiata")).to be_falsey
          end
        end

        describe "#authorised_plugins" do
          it "returns array of user and always allowed plugins" do
            ["refinery_one", "refinery_two", "refinery_three"].each_with_index do |name, index|
              user.plugins.create!(:name => name, :position => index)
            end
            expect(user.authorised_plugins).to eq(user.plugins.collect(&:name) | ::Refinery::Plugins.always_allowed.names)
          end
        end

        describe "plugins association" do
          let(:plugin_list) { ["refinery_one", "refinery_two", "refinery_three"] }
          before { user.plugins = plugin_list }

          it "have a plugins attribute" do
            expect(user).to respond_to(:plugins)
          end

          it "returns plugins in ASC order" do
            expect(user.plugins[0].name).to eq(plugin_list[0])
            expect(user.plugins[1].name).to eq(plugin_list[1])
            expect(user.plugins[2].name).to eq(plugin_list[2])
          end

          it "deletes associated plugins" do
            user.destroy
            expect(UserPlugin.find_by_user_id(user.id)).to be_nil
          end
        end

        describe "#create_first" do
          let(:first_user) do
            FactoryGirl.build(:authentication_devise_user).tap do |user|
              user.create_first
            end
          end

          it "adds refinery role" do
            expect(first_user.roles.collect(&:title)).to include("Refinery")
          end

          it "adds superuser role" do
            expect(first_user.roles.collect(&:title)).to include("Superuser")
          end

          it "adds registered plugins" do
            expect(first_user.plugins.collect(&:name)).to eq(
              %w(refinery_pages refinery_authentication_devise)
              # GLASS: refinery_files && refinery_images are hidden, access from within content editing
            )
          end

          it "returns true on success" do
            allow(first_user).to receive(:valid?).and_return(true)
            expect(first_user.create_first).to eq(true)
          end

          it "returns false on failure" do
            allow(first_user).to receive(:valid?).and_return(false)
            expect(first_user.create_first).to eq(false)
          end
        end

      end
    end
  end
end
