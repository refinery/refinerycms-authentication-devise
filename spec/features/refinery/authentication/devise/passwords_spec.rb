require "spec_helper"

describe "password recovery", :type => :feature do
  let!(:user) { FactoryGirl.create(:authentication_devise_refinery_user, :email => "refinery@example.com", :confirmed_on => DateTime.current) }

  it "asks user to specify email address" do
    visit refinery.login_path
    click_link "I forgot my password"
    expect(page).to have_content("Please enter the email address for your account.")
  end

  context "when existing email specified" do
    it "shows success message" do
      skip "GLASS: need to configure email"
      visit refinery.new_authentication_devise_user_password_path
      fill_in "authentication_devise_user_email", :with => user.email
      click_button "Reset password"
      expect(page).to have_content("An email has been sent to you with a link to reset your password.")
    end
  end

  context "when non-existing email specified" do
    it "shows failure message" do
      visit refinery.new_authentication_devise_user_password_path
      fill_in "authentication_devise_user_email", :with => "none@example.com"
      click_button "Reset password"
      expect(page).to have_content("Sorry, 'none@example.com' isn't associated with any accounts.")
      expect(page).to have_content("Are you sure you typed the correct email address?")
    end
  end

  context "when good reset code" do
    let!(:token) { user.generate_reset_password_token! }

    it "allows to change password" do
      visit refinery.edit_authentication_devise_user_password_path(:reset_password_token => token)
      expect(page).to have_content("Pick a new password")

      fill_in "authentication_devise_user_password", :with => "123456"
      fill_in "authentication_devise_user_password_confirmation", :with => "123456"
      click_button "Reset password"

      # Getting to an admin page signifies success - flash message have been removed, so can't test based on them
      expect(page).to have_content("Company Name")
    end
  end

  context "when invalid reset code" do
    let!(:token) { user.generate_reset_password_token! }

    it "shows error message" do
      visit refinery.edit_authentication_devise_user_password_path(:reset_password_token => "hmmm")
      expect(page).to have_content("You can't access this page without coming from a password reset email")
    end
  end

  context "when expired reset code" do
    let!(:token) { user.generate_reset_password_token! }
    before do
      user.update_attribute(:reset_password_sent_at, 1.day.ago)
    end

    it "shows error message" do
      visit refinery.edit_authentication_devise_user_password_path(:reset_password_token => token)
      expect(page).to have_content("your invitation has expired. Please request a new one")
    end
  end
end
