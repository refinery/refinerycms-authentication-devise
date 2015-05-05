module Refinery
  module Authentication
    module Devise
      class UserPlugin < Refinery::Core::BaseModel

        belongs_to :user

        def self.in_menu
          Refinery::Plugins.registered.in_menu
        end

      end
    end
  end
end
