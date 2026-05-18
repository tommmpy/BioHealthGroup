module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :is_administrador?, :is_medico?, :is_recepcionista?, :is_operario?, :is_disenador?, :is_paciente?
  end

  private

  def is_administrador?
    role_matches?(:administrador)
  end

  def is_medico?
    role_matches?(:medico)
  end

  def is_recepcionista?
    role_matches?(:recepcionista)
  end

  def is_paciente?
    role_matches?(:paciente)
  end

  def is_operario?
    role_matches?(:operario)
  end

  def is_disenador?
    role_matches?(:disenador)
  end

  def role_matches?(key)
    return false unless current_user
    val = current_user[:role]
    if val.is_a?(Integer)
      return User::ROLES[key] == val
    end
    if current_user.respond_to?(:role)
      return current_user.role.to_s.downcase == key.to_s
    end
    current_user[:role].to_s.downcase == key.to_s
  end
end
