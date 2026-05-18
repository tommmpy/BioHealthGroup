class Payment < ApplicationRecord
  audited
  belongs_to :invoice

  enum :payment_method, { cash: 0, card: 1, transfer: 2, mercadopago: 3, other: 4 }

  after_create :update_invoice_status

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_at, presence: true

  def payment_method_label
    { "cash" => "Efectivo", "card" => "Tarjeta", "transfer" => "Transferencia", "mercadopago" => "Mercado Pago", "other" => "Otro" }[payment_method]
  end

  private

  def update_invoice_status
    total_paid = invoice.payments.sum(:amount)
    if total_paid >= invoice.total
      invoice.update(status: :paid, paid_at: Time.current)
    end
  end
end
