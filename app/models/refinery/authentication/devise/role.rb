module Refinery
  module Authentication
    module Devise
      class Role < Refinery::Core::BaseModel

        # Make table_name initializable (necessary for update of pre-authentication-devise-gem apps)
        self.table_name = Refinery::Authentication::Devise.refinery_roles_tablename

        has_and_belongs_to_many :users, :join_table => Refinery::Authentication::Devise.refinery_roles_users_tablename

        before_validation :camelize_title
        validates :title, :uniqueness => true

        def camelize_title(role_title = self.title)
          self.title = role_title.to_s.camelize
        end

        def self.[](title)
          where(:title => title.to_s.camelize).first_or_create!
        end

      end
    end
  end
end
