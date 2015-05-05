require "refinery/core/authorisation_manager"
require "refinery/authentication/devise/authorisation_adapter"

module Refinery
  module Authentication
    module Devise
      class AuthorisationManager < Refinery::Core::AuthorisationManager

        # The user needs the 'refinery' role to access the admin.
        def authenticate!
          unless adapter.current_user.has_role?(:refinery)
            raise Zilch::Authorisation::NotAuthorisedException
          end

          adapter.current_user
        end

        # Override the default adapter specified in the superclass.
        def default_adapter
          @default_adapter ||= Refinery::Authentication::Devise::AuthorisationAdapter.new
        end

        # This allows a user to be supplied, bypassing the usual detection.
        def set_user!(user)
          adapter.current_user = user
        end
      end
    end
  end
end
