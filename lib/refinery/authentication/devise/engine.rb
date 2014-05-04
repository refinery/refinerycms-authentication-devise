module Refinery
  module Authentication
    module Devise
      class Engine < ::Rails::Engine
        extend Refinery::Engine

        isolate_namespace Refinery
        engine_name :refinery_authentication

        config.autoload_paths += %W( #{config.root}/lib )

        initializer "register refinery_authentication_devise plugin" do
          Refinery::Plugin.register do |plugin|
            plugin.pathname = root
            plugin.name = 'refinery_authentication_devise'
            plugin.menu_match = %r{refinery/users$}
            plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.admin_users_path }
          end
        end

        before_inclusion do
          [Refinery::AdminController, ::ApplicationController].each do |c|
            Refinery.include_once(c, Refinery::Authentication::Devise::System)
          end
        end

        config.before_configuration do
          require 'refinery/authentication/devise/initialiser'
        end

        config.after_initialize do
          Refinery.register_extension(Refinery::Authentication::Devise)
        end
      end
    end
  end
end
