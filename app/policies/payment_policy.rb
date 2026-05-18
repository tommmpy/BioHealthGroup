class PaymentPolicy < ApplicationPolicy
  def index?
    InvoicePolicy.new(user, record.invoice).show?
  end

  def create?
    administrador? || recepcionista?
  end
end
