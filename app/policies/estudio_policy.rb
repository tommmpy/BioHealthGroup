class EstudioPolicy < ApplicationPolicy
  def create?
    administrador? || recepcionista?
  end

  def new?
    administrador? || recepcionista?
  end

  def index?
    true
  end

  def show?
    return true if administrador? || recepcionista? || operario?
    return true if medico? && (record.medico_id == user.id || record.pendiente?)
    return record.user_id == user.id if paciente?
    false
  end

  def update?
    administrador? || recepcionista? || medico?
  end

  def edit?
    update?
  end

  def destroy?
    administrador?
  end

  def iniciar?
    medico? || administrador?
  end

  def finalizar?
    medico? || administrador?
  end

  def descargar_informe?
    show?
  end

  def buscar_pacientes?
    index?
  end
end
