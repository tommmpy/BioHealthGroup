class UserDashboardsController < ApplicationController
  def index
    user = current_user

    if is_paciente?
      estados_pendientes = [ Estudio.estados["pendiente"], Estudio.estados["en_progreso"] ]
      @work_total = user.estudios.where(estado: estados_pendientes).count
      @pendientes = user.estudios.where(estado: Estudio.estados["pendiente"]).count
      @ultimo_estudio = user.estudios.order(fecha_estudio: :desc).first
    elsif is_medico?
      @work_total = Estudio.where(medico_id: user.id, estado: Estudio.estados["en_progreso"]).count
      @pendientes = Estudio.where(medico_id: user.id, estado: Estudio.estados["pendiente"]).count
    elsif is_administrador? || is_recepcionista?
      @work_total = Estudio.count
      @pendientes = Estudio.where(estado: Estudio.estados["pendiente"]).count
    end
  end
end
