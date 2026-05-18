module Admin
  class BaseController < ApplicationController
    before_action :require_authentication
    before_action :require_staff!

    private

    def require_staff!
      unless is_administrador? || is_recepcionista? || is_medico? || is_operario?
        redirect_to root_path, alert: "Acceso denegado. Se requieren permisos de administrador."
      end
    end

    def require_admin!
      unless is_administrador?
        redirect_to root_path, alert: "Acceso restringido: Se requieren permisos de administrador."
      end
    end
  end
end
