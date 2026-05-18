class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def administrador?
    user&.administrador?
  end

  def recepcionista?
    user&.recepcionista?
  end

  def medico?
    user&.medico?
  end

  def paciente?
    user&.paciente?
  end

  def operario?
    user&.operario?
  end
end
