require "refinery/core/authorisation_adapter"

module Refinery
  module Authentication
    module Devise
      class AuthorisationAdapter < Refinery::Core::AuthorisationAdapter

        # If no user exists, we use a NilUser (non-admin).
        def current_user
          @current_user ||= Refinery::Authentication::Devise::NilUser.new
        end

        # This method has been added, it does not exist in the superclass.
        def current_user=(set_to_this_user)
          @current_user = set_to_this_user
        end

        def allow?(operation, resource)
          case
          when resource == :site_bar
            current_user.has_role?(:refinery)
          when operation == :plugin
            current_user.active_plugins.names.include?(resource)
          when operation == :controller
            current_user.active_plugins.any? do |plugin|
              Regexp.new(plugin.menu_match) === resource
            end
          else
            false
          end
        end

      end
    end
  end
end
