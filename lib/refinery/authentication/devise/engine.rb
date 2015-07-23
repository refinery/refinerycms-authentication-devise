module Refinery
  module Authentication
    module Devise
      class Engine < ::Rails::Engine
        include Refinery::Engine

        isolate_namespace Refinery::Authentication::Devise
        engine_name :refinery_authentication_devise

        config.autoload_paths += %W( #{config.root}/lib )

        before_inclusion do
          Refinery::Plugin.register do |plugin|
            plugin.pathname = root
            plugin.name = 'refinery_authentication_devise'
            plugin.menu_match = %r{refinery/(authentication/devise/)?users$}
            plugin.url = proc {
              Refinery::Core::Engine.routes.url_helpers.authentication_devise_admin_users_path
            }
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

          Rails.application.reload_routes!
          Refinery::Core.refinery_logout_path =
            Refinery::Core::Engine.routes.url_helpers.logout_path
        end
      end
    end
  end
end
