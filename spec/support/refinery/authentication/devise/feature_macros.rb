module Refinery
  module Authentication
    module Devise
      module FeatureMacros

        def refinery_login
          before do
            visit refinery.login_path

            fill_in "Username or email", with: logged_in_user.username
            fill_in "Password", with: "refinerycms"

            click_button "Sign in"
          end
        end

        def refinery_login_with(factory)
          let!(:logged_in_user) { FactoryGirl.create(factory) }

          refinery_login
        end

      end
    end
  end
end

RSpec.configure do |config|
  config.extend Refinery::Authentication::Devise::FeatureMacros, type: :feature
end
