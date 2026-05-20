class ProductionOrder < ApplicationRecord
  audited
  belongs_to :estudio
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :production_tasks, dependent: :destroy

  enum :status, { awaiting_payment: 0, pending: 1, in_progress: 2, completed: 3, cancelled: 4 }, default: :awaiting_payment

  validates :status, presence: true

  scope :awaiting_payment_orders, -> { where(status: :awaiting_payment) }
  scope :pending_orders, -> { where(status: :pending) }
  scope :in_progress_orders, -> { where(status: :in_progress) }
  scope :completed_orders, -> { where(status: :completed) }
  scope :cancelled_orders, -> { where(status: :cancelled) }
  scope :overdue, -> { awaiting_payment.or(pending).or(in_progress).where("due_date < ?", Date.current) }

  TASKS = [
    { name: "Diseño de plantar", role: :disenador, position: 1 },
    { name: "Armado de taco y fresadora", role: :operario, position: 2 },
    { name: "Lijado", role: :operario, position: 3 },
    { name: "Pegado de cover", role: :operario, position: 4 },
    { name: "Terminación", role: :operario, position: 5 },
    { name: "Grabado", role: :operario, position: 6 }
  ].freeze

  def create_default_tasks!
    TASKS.each do |task|
      production_tasks.create!(
        name: task[:name],
        assigned_role: User.roles[task[:role]],
        position: task[:position]
      )
    end
  end

  def all_tasks_completed?
    production_tasks.where(completed: false).none?
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id status notes due_date completed_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[estudio assigned_to production_tasks]
  end
end
