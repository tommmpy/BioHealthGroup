class ProductionTask < ApplicationRecord
  belongs_to :production_order
  belongs_to :completed_by, class_name: "User", optional: true

  scope :pending, -> { where(completed: false) }
  scope :done, -> { where(completed: true) }
  scope :ordered, -> { order(:position) }

  def assigned_role_name
    User::ROLES.key(assigned_role)
  end

  def assignable_by?(user)
    user.role == assigned_role || user.administrador?
  end
end
