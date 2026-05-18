class InvoicePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if administrador? || recepcionista?
    return record.user_id == user.id if paciente?
    false
  end

  def create?
    administrador? || recepcionista?
  end

  def new?
    create?
  end

  def mark_sent?
    administrador? || recepcionista?
  end

  def mark_paid?
    administrador? || recepcionista?
  end

  def download_pdf?
    show?
  end
end
