class AppointmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if administrador? || recepcionista? || operario?
    return true if medico? && (record.medico_id == user.id || record.user_id == user.id)
    return record.user_id == user.id if paciente?
    false
  end

  def new?
    administrador? || recepcionista?
  end

  def create?
    new?
  end

  def edit?
    administrador? || recepcionista? || medico?
  end

  def update?
    edit?
  end

  def destroy?
    administrador?
  end

  def confirm?
    administrador? || recepcionista?
  end

  def cancel?
    administrador? || recepcionista? || medico? || (paciente? && record.user_id == user.id)
  end
end
