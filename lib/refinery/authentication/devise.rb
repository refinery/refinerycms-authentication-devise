require 'refinerycms-core'
require 'action_mailer'
require 'devise'
require 'friendly_id'

module Refinery
  autoload :AuthenticationDeviseGenerator, 'generators/refinery/authentication/devise/authentication_generator'
  autoload :AuthenticationSystem, 'refinery/authenticated_system'

  module Authentication
    module Devise
      require 'refinery/authentication/devise/engine'
      require 'refinery/authentication/devise/configuration'

      class << self
        def factory_paths
          @factory_paths ||= [ root.join("spec/factories").to_s ]
        end

        def root
          @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
        end
      end
    end
  end
end
