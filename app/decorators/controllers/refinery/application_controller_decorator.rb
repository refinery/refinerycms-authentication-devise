Refinery::ApplicationController.module_eval do
  private
  def authorisation_manager
    @authorisation_manager ||= Refinery::Authentication::Devise::AuthorisationManager.new
  end
end
