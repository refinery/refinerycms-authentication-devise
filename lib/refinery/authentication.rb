module Refinery
  module Authentication
    extend self

    def configure(&block)
      Refinery.deprecate(
        'Refinery::Authentication#configure',
        when: '1.1 of refinerycms-authentication-devise',
        replacement: 'Refinery::Authentication::Devise#configure'
      )

      Refinery::Authentication::Devise.configure(&block)
    end

    def superuser_can_assign_roles
      Refinery.deprecate(
        'Refinery::Authentication#superuser_can_assign_roles',
        when: '1.1 of refinerycms-authentication-devise',
        replacement: 'Refinery::Authentication::Devise#superuser_can_assign_roles'
      )

      Refinery::Authentication::Devise.superuser_can_assign_roles
    end

    def superuser_can_assign_roles=(value)
      Refinery.deprecate(
        'Refinery::Authentication#superuser_can_assign_roles=',
        when: '1.1 of refinerycms-authentication-devise',
        replacement: 'Refinery::Authentication::Devise#superuser_can_assign_roles='
      )

      Refinery::Authentication::Devise.superuser_can_assign_roles = value
    end

    def email_from_name
      Refinery.deprecate(
        'Refinery::Authentication#email_from_name',
        when: '1.1 of refinerycms-authentication-devise',
        replacement: 'Refinery::Authentication::Devise#email_from_name'
      )

      Refinery::Authentication::Devise.email_from_name
    end

    def email_from_name=(value)
      Refinery.deprecate(
        'Refinery::Authentication#email_from_name=',
        when: '1.1 of refinerycms-authentication-devise',
        replacement: 'Refinery::Authentication::Devise#email_from_name='
      )

      Refinery::Authentication::Devise.email_from_name = value
    end
  end
end
