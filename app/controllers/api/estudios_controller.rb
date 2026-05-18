module Api
  class EstudiosController < BaseController
    def index
      @estudios = if current_user.paciente?
        current_user.estudios
      elsif is_medico?
        Estudio.where(medico: current_user)
      else
        Estudio.all
      end
      @estudios = @estudios.order(created_at: :desc)
    end

    def show
      @estudio = if current_user.paciente?
        current_user.estudios.find(params[:id])
      elsif is_medico?
        Estudio.where(medico: current_user).find(params[:id])
      else
        Estudio.find(params[:id])
      end
    end
  end
end
