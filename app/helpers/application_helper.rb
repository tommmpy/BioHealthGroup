module ApplicationHelper
  include Pagy::Frontend

  def role_badge_class(role)
    case role.to_s
    when "administrador" then "bg-purple-500/10 text-purple-400 border-purple-500/20"
    when "medico"        then "bg-blue-500/10 text-blue-400 border-blue-500/20"
    when "recepcionista" then "bg-teal-500/10 text-teal-400 border-teal-500/20"
    when "operario"      then "bg-yellow-500/10 text-yellow-400 border-yellow-500/20"
    when "disenador"     then "bg-pink-500/10 text-pink-400 border-pink-500/20"
    else "bg-gray-500/10 text-gray-400 border-gray-500/20"
    end
  end

  def status_dot_class(status)
    User::STATUS_COLORS[status.to_s] || "bg-gray-600"
  end

  def format_datetime(dt, format: :default)
    return "-" if dt.blank?
    I18n.l(dt, format: format)
  end

  def format_date(date, format: :default)
    return "-" if date.blank?
    I18n.l(date, format: format)
  end

  def format_currency(amount)
    return "-" if amount.nil?
    number_to_currency(amount, unit: "$", separator: ",", delimiter: ".", precision: 2, format: "%u %n")
  end
end
