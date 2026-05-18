class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Pagy::Backend
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def current_user
    @current_user ||= Current.user
  end
  helper_method :current_user

  def require_admin
    unless current_user && (is_administrador? || is_medico? || is_recepcionista? || is_operario?)
      redirect_to root_path, alert: "Acceso denegado."
    end
  end
end
