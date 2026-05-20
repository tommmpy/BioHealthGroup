class ProductionOrder < ApplicationRecord
  audited
  belongs_to :estudio
  belongs_to :assigned_to, class_name: "User", optional: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }, default: :pending

  validates :status, presence: true

  scope :pending_orders, -> { where(status: :pending) }
  scope :in_progress_orders, -> { where(status: :in_progress) }
  scope :completed_orders, -> { where(status: :completed) }
  scope :cancelled_orders, -> { where(status: :cancelled) }
  scope :overdue, -> { pending.or(in_progress).where("due_date < ?", Date.current) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id status notes due_date completed_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[estudio assigned_to]
  end
end
