module Refinery
  module Authentication
    module Devise
      module FeatureMacros

        def refinery_login_with_devise(factory)
          let!(:logged_in_user) { FactoryGirl.create(factory) }

          before do
            visit refinery.login_path

            fill_in "authentication_devise_user[login]", with: logged_in_user.username
            fill_in "authentication_devise_user[password]", with: "refinerycms"

            click_button "Sign in"
          end
        end

      end
    end
  end
end

RSpec.configure do |config|
  config.extend Refinery::Authentication::Devise::FeatureMacros, type: :feature
end
