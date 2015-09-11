module Refinery
  module Authentication
    module Devise
      include ActiveSupport::Configurable

      config_accessor :superuser_can_assign_roles, :email_from_name, :refinery_roles_users_tablename, :refinery_roles_tablename

      self.superuser_can_assign_roles = false
      self.email_from_name = "no-reply"
      self.refinery_roles_users_tablename = :refinery_authentication_devise_roles_users
      self.refinery_roles_tablename = :refinery_authentication_devise_roles
      
      class << self
        def email_from_name
          ::I18n.t(
            'email_from_name',
            scope: 'refinery.authentication.config',
            default: config.email_from_name
          )
        end
      end
    end
  end
end
