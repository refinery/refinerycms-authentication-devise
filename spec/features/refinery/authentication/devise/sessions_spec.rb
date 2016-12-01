require "spec_helper"

describe "sign in", :type => :feature do
  let(:login_path) { refinery.new_authentication_devise_user_session_path }
  let(:login_retry_path) { refinery.authentication_devise_user_session_path }
  let(:admin_path) { "/#{Refinery::Core.backend_route}" }
  let!(:user) {
    FactoryGirl.create(:authentication_devise_refinery_user, :username => "ugisozols",
                                       :password => "123456",
                                       :password_confirmation => "123456")
  }

  before do
    visit refinery.login_path
  end

  it "shows login form" do
    expect(page).to have_content("Refinery CMS")
    expect(page).to have_content("Sign in")
    expect(page).to have_content("I forgot my password")
    expect(page).to have_selector("a[href*='/refinery/users/password/new']")
  end

  context "when supplied data is valid" do
    it "logs in user" do
      fill_in "authentication_devise_user[login]", :with => "ugisozols"
      fill_in "authentication_devise_user[password]", :with => "123456"
      click_button "Sign in"

      # alerts have been removed, being on the "admin_path" is enough info to know it worked
      # expect(page).to have_content("Signed in successfully.")
      expect(current_path).to match(/\A#{admin_path}/)
    end
  end

  context "when supplied data is not valid" do
    it "shows flash error" do
      fill_in "authentication_devise_user[login]", :with => "Hmmm"
      fill_in "authentication_devise_user[password]", :with => "Hmmm"
      click_button "Sign in"
      expect(page).to have_content("Sorry, your login or password was incorrect.")
      expect(current_path).to eq(login_retry_path)
    end
  end
end

describe 'user sign up', :type => :feature do
  before do
    Refinery::Authentication::Devise::User.delete_all
  end

  describe 'when there are no users' do
    it 'allows user creation' do
      # Verify that we can access the sign up page.
      visit Refinery::Core.backend_path
      expect(page).to have_content("Please create the first account")

      # Fill in user details.
      fill_in 'user[username]', :with => 'rspec'
      fill_in 'user[email]', :with => 'rspec@example.com'
      fill_in 'user[password]', :with => 'spectacular'
      fill_in 'user[password_confirmation]', :with => 'spectacular'

      # Sign up and verify!
      expect {
        click_button "Sign up"
      }.to change(Refinery::Authentication::Devise::User, :count).from(0).to(1)
      expect(page).to have_content("Company Name")
    end
  end
end

describe 'redirects', :type => :feature do
  let(:protected_path) { refinery.new_authentication_devise_admin_user_path }
  let(:login_path) { refinery.login_path }

  before do
    FactoryGirl.create(:authentication_devise_refinery_user,
      :username => "ugisozols",
      :password => "123456",
      :password_confirmation => "123456"
    )
  end

  context "when visiting a protected path" do
    before { visit protected_path }

    it "redirects to the login" do
      expect(current_path).to eq(login_path)
    end

    it "shows login form" do
      expect(page).to have_content("Refinery CMS")
      expect(page).to have_content("Sign in")
      expect(page).to have_content("I forgot my password")
      expect(page).to have_selector("a[href*='/refinery/users/password/new']")
    end

    it "redirects to the protected path on login" do
      fill_in "authentication_devise_user[login]", :with => "ugisozols"
      fill_in "authentication_devise_user[password]", :with => "123456"
      page.click_button "Sign in"
      expect(current_path).to eq(protected_path)
    end
  end

end

describe "sign out", :type => :feature do
  before do
    FactoryGirl.create(:authentication_devise_refinery_user,
      :username => "ugisozols",
      :password => "123456",
      :password_confirmation => "123456"
    )
    visit refinery.login_path
    fill_in "authentication_devise_user[login]", :with => "ugisozols"
    fill_in "authentication_devise_user[password]", :with => "123456"
    click_button "Sign in"
  end

  context "when I sign out" do
    before { click_on "Log Out" }

    it "redirects me back to the sign in page" do
      expect(current_path).to eq(refinery.login_path)
      expect(page).to have_content("Signed out successfully")
    end
  end
end
