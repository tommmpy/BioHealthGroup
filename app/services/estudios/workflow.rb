class Estudios::Workflow < ApplicationService
  ACTIONS = %w[iniciar finalizar].freeze

  def initialize(estudio, action, current_user: nil)
    @estudio = estudio
    @action = action.to_s
    @current_user = current_user
  end

  def call
    case @action
    when "iniciar" then iniciar
    when "finalizar" then finalizar
    else { success: false, estudio: @estudio }
    end
  end

  private

  def iniciar
    if @estudio.update(estado: :en_progreso, medico_id: @current_user&.id)
      { success: true, estudio: @estudio }
    else
      { success: false, estudio: @estudio }
    end
  end

  def finalizar
    if @estudio.metar_paciente.blank?
      return { success: false, estudio: @estudio, alert: "Debe ingresar el METAR antes de finalizar el estudio." }
    end

    if @estudio.update(estado: :finalizado)
      { success: true, estudio: @estudio, notice: "Estudio finalizado correctamente." }
    else
      { success: false, estudio: @estudio, alert: "No fue posible finalizar el estudio." }
    end
  end
end
