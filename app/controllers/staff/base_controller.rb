module Staff
  class BaseController < ApplicationController
    before_action :require_authentication
    before_action :require_staff!

    private

    def require_staff!
      unless is_administrador? || is_recepcionista? || is_medico? || is_operario? || is_disenador?
        redirect_to root_path, alert: "Acceso denegado."
      end
    end
  end
end
