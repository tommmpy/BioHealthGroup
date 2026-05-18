module Roleable
  extend ActiveSupport::Concern

  ROLES = { paciente: 0, recepcionista: 1, medico: 2, operario: 3, administrador: 4, disenador: 5 }.freeze
  USER_TYPES = { persona: 0, empresa: 1 }.freeze

  ROLE_HUMANIZED = {
    "paciente" => "Paciente",
    "recepcionista" => "Recepcionista",
    "medico" => "Médico",
    "operario" => "Operario",
    "administrador" => "Administrador",
    "disenador" => "Diseñador"
  }.freeze

  included do
    ROLES.each do |k, v|
      scope k, -> { where(role: v) }
    end

    ROLES.each_key do |k|
      define_method("#{k}?") do
        current = self[:role]
        return false if current.nil?
        current.is_a?(Integer) ? current == ROLES[k] : current.to_s == k.to_s
      end
    end

    before_validation :normalize_role_value
  end

  class_methods do
    def roles
      ROLES
    end

    def user_types
      USER_TYPES
    end

    def role_options
      ROLE_HUMANIZED.map { |key, human| [ human, key ] }
    end
  end

  def role
    val = self[:role]
    return nil if val.nil?
    val.is_a?(Integer) ? ROLES.key(val).to_s : val.to_s
  end

  def role=(v)
    if v.nil?
      self[:role] = nil
    elsif v.is_a?(String) || v.is_a?(Symbol)
      key = v.to_s
      self[:role] = ROLES.key?(key.to_sym) ? ROLES[key.to_sym] : v
    else
      self[:role] = v
    end
  end

  def user_type
    val = self[:user_type]
    return nil if val.nil?
    val.is_a?(Integer) ? USER_TYPES.key(val).to_s : val.to_s
  end

  def user_type=(v)
    if v.nil?
      self[:user_type] = nil
    elsif v.is_a?(String) || v.is_a?(Symbol)
      key = v.to_s
      self[:user_type] = USER_TYPES[key.to_sym] if USER_TYPES.key?(key.to_sym)
    else
      self[:user_type] = v
    end
  end

  def empresa?
    val = self[:user_type]
    return false if val.nil?
    val.is_a?(Integer) ? val == USER_TYPES[:empresa] : user_type.to_s == "empresa"
  end

  def persona?
    val = self[:user_type]
    return false if val.nil?
    val.is_a?(Integer) ? val == USER_TYPES[:persona] : user_type.to_s == "persona"
  end

  private

  def normalize_role_value
    raw = role_before_type_cast rescue self[:role]
    return if raw.blank?
    return if raw.is_a?(Integer) || raw.to_s =~ /\A\d+\z/

    str = raw.to_s
    return self.role = str.to_sym if self.class.roles.key?(str.to_sym)

    lower = str.downcase
    found = ROLE_HUMANIZED.find { |_k, v| v.downcase == lower }
    return self.role = found.first if found

    candidate = I18n.transliterate(str).parameterize(separator: "_").tr("-", "_")
    self.role = candidate.to_sym if self.class.roles.key?(candidate.to_sym)
  end
end
