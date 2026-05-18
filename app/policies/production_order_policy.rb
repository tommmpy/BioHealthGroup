class ProductionOrderPolicy < ApplicationPolicy
  def index?
    administrador? || operario?
  end

  def show?
    administrador? || (operario? && record.assigned_to_id == user.id)
  end

  def update?
    administrador?
  end

  def start?
    administrador? || operario?
  end

  def complete?
    administrador? || operario?
  end
end
