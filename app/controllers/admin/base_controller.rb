module Admin
  class BaseController < ApplicationController
    before_action :require_authentication
    before_action :require_admin!

    private

    def require_admin!
      unless is_administrador?
        redirect_to root_path, alert: "Acceso denegado. Se requieren permisos de administrador."
      end
    end
  end
end
