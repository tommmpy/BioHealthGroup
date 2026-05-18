class User < ApplicationRecord
  include Roleable
  include CedulaIdentidad

  STATUSES = { disponible: 0, ausente: 1, no_molestar: 2, desconectado: 3 }.freeze
  STATUS_LABELS = { "disponible" => "Conectado", "ausente" => "Ausente", "no_molestar" => "No molestar", "desconectado" => "Desconectado" }.freeze
  STATUS_COLORS = { "disponible" => "bg-green-500", "ausente" => "bg-yellow-500", "no_molestar" => "bg-red-500", "desconectado" => "bg-gray-600" }.freeze

  scope :disponible, -> { where(status: STATUSES[:disponible]) }
  scope :ausente, -> { where(status: STATUSES[:ausente]) }
  scope :no_molestar, -> { where(status: STATUSES[:no_molestar]) }
  scope :desconectado, -> { where(status: STATUSES[:desconectado]) }
  scope :notificable, -> { where.not(status: STATUSES[:no_molestar]) }

  has_secure_password

  audited

  belongs_to :branch
  has_many :sessions, dependent: :destroy
  has_many :estudios, dependent: :nullify
  has_many :chat_room_participants, class_name: "Chat::Participant", dependent: :destroy, foreign_key: :user_id
  has_many :conversations, through: :chat_room_participants, source: :conversation
  has_many :messages, class_name: "Chat::Message", dependent: :destroy, foreign_key: :user_id
  has_many :notifications, dependent: :destroy
  has_many :appointments, dependent: :nullify
  has_many :assigned_appointments, class_name: "Appointment", foreign_key: :medico_id, dependent: :nullify

  validates :user_type, presence: true
  attr_accessor :skip_contacto_root

  validates :contacto_root, presence: true, if: :contacto_root_required?

  validates :first_name, :last_name, :ci, :email_address, :phone_number, :branch_id, :address, presence: true
  validates :first_name, :last_name, length: { minimum: 2, maximum: 50 }
  validates :first_name, :last_name, format: { with: /\A[\p{L}\s']+\z/, message: "solo permite letras y espacios" }
  validates :email_address, uniqueness: { case_sensitive: false },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :phone_number, format: { with: /\A(\+?598|0)9\d{7}\z/, message: "debe ser un formato de celular válido (ej: 099123456)" }
  validates :address, length: { maximum: 100 }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :password, format: {
    with: /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])/,
    message: "debe incluir al menos una mayúscula, una minúscula y un número"
  }, if: -> { password.present? }

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt.last(10)
  end

  after_initialize :set_default_role, if: :new_record?

  STATUSES.each_key do |k|
    define_method("#{k}?") do
      current = self[:status]
      return false if current.nil?
      current.is_a?(Integer) ? current == STATUSES[k] : current.to_s == k.to_s
    end
  end

  def status
    val = self[:status]
    return nil if val.nil?
    val.is_a?(Integer) ? STATUSES.key(val).to_s : val.to_s
  end

  def status_label
    STATUS_LABELS[status] || "Desconectado"
  end

  def status=(v)
    if v.nil?
      self[:status] = nil
    elsif v.is_a?(String) || v.is_a?(Symbol)
      key = v.to_sym
      self[:status] = STATUSES.key?(key) ? STATUSES[key] : v
    else
      self[:status] = v
    end
  end

  def age
    return nil if birthday.blank?
    now = Time.zone.now.to_date
    now.year - birthday.year - ((now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day)) ? 0 : 1)
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "address", "birthday", "ci", "contacto_root", "created_at", "email_address", "first_name", "id", "last_active_at", "last_name", "phone_number", "role", "status", "updated_at", "user_type" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "branch", "estudios" ]
  end

  private

  def contacto_root_required?
    return false if skip_contacto_root
    empresa? || (persona? && birthday.present? && age < 18)
  end

  def set_default_role
    self.role ||= :paciente
  end
end
