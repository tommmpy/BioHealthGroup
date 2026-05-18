class Appointment < ApplicationRecord
  audited

  belongs_to :user
  belongs_to :estudio, optional: true
  belongs_to :medico, class_name: "User", optional: true
  belongs_to :branch

  enum :status, {
    pending: 0,
    confirmed: 1,
    in_progress: 2,
    completed: 3,
    cancelled: 4
  }, default: :pending

  validates :title, :starts_at, :ends_at, :user, :branch, presence: true
  validate :ends_at_must_be_after_starts_at

  scope :upcoming, -> { where("starts_at > ?", Time.current).order(starts_at: :asc) }
  scope :today, -> { where(starts_at: Time.current.beginning_of_day..Time.current.end_of_day).order(starts_at: :asc) }
  scope :by_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day).order(starts_at: :asc) }

  STATUS_LABELS = {
    "pending" => "Pendiente",
    "confirmed" => "Confirmado",
    "in_progress" => "En progreso",
    "completed" => "Completado",
    "cancelled" => "Cancelado"
  }.freeze

  STATUS_COLORS = {
    "pending" => "text-yellow-400 bg-yellow-500/10 border-yellow-500/20",
    "confirmed" => "text-blue-400 bg-blue-500/10 border-blue-500/20",
    "in_progress" => "text-orange-400 bg-orange-500/10 border-orange-500/20",
    "completed" => "text-green-400 bg-green-500/10 border-green-500/20",
    "cancelled" => "text-red-400 bg-red-500/10 border-red-500/20"
  }.freeze

  def self.ransackable_attributes(auth_object = nil)
    %w[title starts_at ends_at status created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user estudio medico branch]
  end

  def status_label
    STATUS_LABELS[status] || status.humanize
  end

  private

  def ends_at_must_be_after_starts_at
    return if ends_at.blank? || starts_at.blank?
    if ends_at <= starts_at
      errors.add(:ends_at, "debe ser posterior a la fecha de inicio")
    end
  end
end
