require "spec_helper"

describe "User admin page", :type => :feature do
  refinery_login_with_devise :authentication_devise_refinery_superuser

  describe "new/create" do
    def visit_and_fill_form
      visit refinery.authentication_devise_admin_users_path
      click_link "New user"

      fill_in "user[username]", :with => "testerdude"
      fill_in "user[email]", :with => "test@example.com"
      # Password is now filled by the user when they activate their account
      #fill_in "user[password]", :with => "123456"
      #fill_in "user[password_confirmation]", :with => "123456"

      # Moc out sending password instructions so we don't have to deal with email
      allow_any_instance_of(Refinery::Authentication::Devise::User).to receive(:send_reset_password_instructions).and_return(true)
    end

    it "can create a user" do
      visit_and_fill_form

      click_button "Send Invitation"

      expect(page).to have_content("testerdude")
    end

    context "when assigning roles config is enabled" do
      before do
        allow(Refinery::Authentication::Devise).to receive(:superuser_can_assign_roles).and_return(true)
      end

      it "allows superuser to assign roles" do
        visit_and_fill_form

        within "#roles" do
          check "roles_#{Refinery::Authentication::Devise::Role.first.title.downcase}"
        end
        click_button "Send Invitation"

        expect(page).to have_content("testerdude")
      end
    end
  end

  describe "edit/update" do
    it "can update a user" do
      visit refinery.authentication_devise_admin_users_path
      click_link "#{logged_in_user.username}"

      fill_in "Username", :with => "cmsrefinery"
      fill_in "Email", :with => "cms@example.com"
      click_button "Update"

      expect(page).to have_content("cmsrefinery")
    end

    let(:dotty_user) { FactoryGirl.create(:authentication_devise_refinery_user, :username => 'user.name.with.lots.of.dots') }
    it "accepts a username with a '.' in it" do
      dotty_user # create the user
      visit refinery.authentication_devise_admin_users_path

      expect(page).to have_css("#user_#{dotty_user.id}")

      within "#user_#{dotty_user.id}" do
        click_link dotty_user.username
      end

      expect(page).to have_css("form#edit_user_#{dotty_user.id}")
    end
  end

  describe "destroy" do
    let!(:user) {
      FactoryGirl.create(:authentication_devise_refinery_user, username: "ugisozols")
    }

    it "can only destroy regular users" do
      skip "GLASS: Can't find the delete button"
      visit refinery.authentication_devise_admin_users_path
      expect(page).to have_selector("a[href='/refinery/users/#{user.username}']")
      expect(page).to have_no_selector("a[href='/refinery/users/#{logged_in_user.username}']")

      click_link "Remove this user"
      #find("button.delete[data-url='/refinery/users/#{user.username}'").trigger(:click)
      expect(page).to have_content("'#{user.username}' was successfully removed.") # these don't show up anymore...
      expect(page).to have_content("#{logged_in_user.username} (#{logged_in_user.email})")
    end
  end
end
