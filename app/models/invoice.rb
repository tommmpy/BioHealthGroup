class Invoice < ApplicationRecord
  audited
  belongs_to :user
  belongs_to :estudio, optional: true
  has_many :payments, dependent: :destroy

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3, cancelled: 4 }

  before_create :generate_invoice_number

  validates :subtotal, :total, :due_date, presence: true
  validates :subtotal, :total, :tax_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :invoice_number, uniqueness: true, allow_nil: true

  scope :paid_in_range, ->(range) { where(status: :paid, paid_at: range) }

  def self.ransackable_attributes(auth_object = nil)
    %w[invoice_number status subtotal total due_date paid_at created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user payments]
  end

  def status_label
    { "draft" => "Borrador", "sent" => "Enviada", "paid" => "Pagada", "overdue" => "Vencida", "cancelled" => "Anulada" }[status]
  end

  def status_color
    { "draft" => "bg-gray-500/10 text-gray-400 border-gray-500/20",
      "sent" => "bg-blue-500/10 text-blue-400 border-blue-500/20",
      "paid" => "bg-green-500/10 text-green-400 border-green-500/20",
      "overdue" => "bg-red-500/10 text-red-400 border-red-500/20",
      "cancelled" => "bg-gray-500/10 text-gray-400 border-gray-500/20" }[status]
  end

  private

  def generate_invoice_number
    year = Time.current.year.to_s
    last = Invoice.where("invoice_number LIKE ?", "FAC-#{year}-%").maximum(:invoice_number)
    seq = if last
            last.split("-").last.to_i + 1
    else
            1
    end
    self.invoice_number = "FAC-#{year}-#{seq.to_s.rjust(5, '0')}"
  end
end
