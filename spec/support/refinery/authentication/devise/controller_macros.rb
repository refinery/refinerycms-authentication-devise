module Refinery
  module Authentication
    module Devise
      module ControllerMacros
        def self.extended(base)
          base.send :include, ::Devise::Test::ControllerHelpers
        end

        def refinery_login_with_devise(*roles)
          roles = handle_deprecated_roles!(roles).flatten
          let(:logged_in_user) do
            FactoryGirl.create(:authentication_devise_user).tap do |user|
              roles.each do |role|
                user.add_role(role)
              end
            end
          end
          before do
            @request.env["devise.mapping"] = ::Devise.mappings[:authentication_devise_user]
            sign_in logged_in_user
          end
        end

        def factory_user(factory)
          let(:logged_in_user) { FactoryGirl.create(factory) }
          before do
            @request.env["devise.mapping"] = ::Devise.mappings[:authentication_devise_user]
            sign_in logged_in_user
          end
        end

        private
        def handle_deprecated_roles!(*roles)
          mappings = {
            :user => [],
            :refinery_user => [:refinery],
            :refinery_superuser => [:refinery, :superuser]
          }
          mappings[roles.flatten.first] || roles
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.extend Refinery::Authentication::Devise::ControllerMacros, type: :controller
end
