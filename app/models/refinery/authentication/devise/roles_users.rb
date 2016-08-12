module Refinery
  module Authentication
    module Devise
      class RolesUsers < Refinery::Core::BaseModel
        
        # Make table_name initializable (necessary for update of pre-authentication-devise-gem apps)
        self.table_name = Refinery::Authentication::Devise.refinery_roles_users_tablename

        belongs_to :role
        belongs_to :user

      end
    end
  end
end
