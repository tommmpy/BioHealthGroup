module CedulaIdentidad
  extend ActiveSupport::Concern

  included do
    validates :ci, uniqueness: true,
                   numericality: { only_integer: true, message: "debe contener solo números sin puntos ni guiones" },
                   length: { in: 7..9 }

    validate :ci_must_be_valid
    normalizes :ci, with: ->(ci) { ci.to_s.gsub(/\D/, "") }
  end

  private

  def ci_must_be_valid
    return if ci.blank?

    clean_ci = ci.to_s.gsub(/\D/, "")

    unless clean_ci.length.between?(7, 8)
      errors.add(:ci, "debe tener entre 7 y 8 dígitos")
      return
    end

    full_ci = clean_ci.rjust(8, "0")
    digits = full_ci.split("").map(&:to_i)

    weights = [ 2, 9, 8, 7, 6, 3, 4 ]
    sum = 0

    7.times do |i|
      sum += digits[i] * weights[i]
    end

    check_digit = (10 - (sum % 10)) % 10

    if check_digit != digits.last
      errors.add(:ci, "no es válida (error en dígito verificador)")
    end
  end
end
