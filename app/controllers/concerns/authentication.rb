module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current
    before_action :require_authentication
    before_action :track_activity
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    Current.session.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def set_current
    if (session_id = cookies.signed[:session_id]) && (sess = Session.active.find_by(id: session_id))
      Current.session = sess
      Current.user = sess.user
    end
  end

  def resume_session
    sess = find_session
    Current.session = sess
    Current.user = sess&.user
    sess
  end

  def track_activity
    user = Current.user
    return unless user
    return if user.no_molestar?

    now = Time.current
    last_active = user.last_active_at
    five_min_ago = 5.minutes.ago

    if user.disponible?
      if last_active.present? && last_active < five_min_ago
        user.update_columns(status: User::STATUSES[:ausente], last_active_at: now)
      elsif last_active.nil? || last_active < 1.minute.ago
        user.update_column(:last_active_at, now)
      end
    end

    sess = Current.session
    return unless sess
    return if params[:controller] == "sessions" && params[:action].in?(%w[new create choose recover force_new])

    log_activity(sess, now) if request.post? || request.put? || request.patch? || request.delete?
  end

  def log_activity(sess, now)
    description = build_activity_description
    return unless description

    url = request.original_url
    entry = {
      description: description,
      url: url,
      method: request.method,
      controller: params[:controller],
      action: params[:action],
      visited_at: now.iso8601
    }
    sess.update_columns(last_url: url, activity_log: (sess.activity_log || []) + [ entry ])
  end

  def build_activity_description
    c = params[:controller]
    a = params[:action]
    id = params[:id]

    case [ c, a ]
    in [ "admin/users", "create" ]     then "Creó un nuevo usuario"
    in [ "admin/users", "update" ]     then "Actualizó el usuario ##{id}"
    in [ "admin/users", "destroy" ]    then "Eliminó el usuario ##{id}"
    in [ "admin/estudios", "create" ]  then "Agendó un nuevo estudio"
    in [ "admin/estudios", "update" ]  then "Actualizó el estudio ##{id}"
    in [ "admin/estudios", "destroy" ] then "Eliminó el estudio ##{id}"
    in [ "profiles", "update" ]        then "Actualizó su perfil"
    in [ "profiles", "update_status" ] then "Cambió su estado a #{params[:status]}"
    in [ "registrations", "create" ]   then "Se registró en la plataforma"
    in [ "sessions", "destroy" ]       then "Cerró sesión"
    in [ "passwords", "update" ]       then "Cambió su contraseña"
    in [ "chat/conversations", "create" ] then "Inició una conversación"
    in [ "chat/conversations", "close" ]          then "Cerró la conversación ##{id}"
    in [ "chat/conversations", "reopen" ]         then "Reabrió la conversación ##{id}"
    in [ "chat/conversations", "request_reopen" ] then "Solicitó reapertura de la conversación ##{id}"
    in [ "chat/conversations", "accept" ]         then "Aceptó la conversación ##{id}"
    in [ "chat/messages", "create" ]   then "Envió un mensaje en el chat"
    in [ "admin/hero_slides", * ]      then "Modificó slides del hero"
    in [ "admin/testimonials", * ]     then "Modificó testimonios"
    in [ "admin/process_steps", * ]    then "Modificó pasos del proceso"
    in [ "admin/branches", "toggle_status" ] then "Cambió estado de la sucursal ##{id} (#{params[:status]})"
    in [ "admin/branches", * ]         then "Modificó sucursales"
    in [ "admin/estudios", "iniciar" ] then "Inició el estudio ##{id}"
    in [ "admin/estudios", "finalizar" ] then "Finalizó el estudio ##{id}"
    in [ "admin/invoices", "create" ]    then "Creó la factura ##{id}"
    in [ "admin/invoices", "mark_sent" ] then "Marcó la factura ##{id} como enviada"
    in [ "admin/invoices", "mark_paid" ] then "Marcó la factura ##{id} como pagada"
    in [ "admin/payments", "create" ]    then "Registró un pago en la factura ##{params[:invoice_id]}"
    in [ "admin/appointments", "create" ]  then "Agendó un nuevo turno"
    in [ "admin/appointments", "update" ]  then "Actualizó el turno ##{id}"
    in [ "admin/appointments", "destroy" ] then "Eliminó el turno ##{id}"
    in [ "admin/appointments", "confirm" ] then "Confirmó el turno ##{id}"
    in [ "admin/appointments", "cancel" ]  then "Canceló el turno ##{id}"
    in [ "admin/products", "create" ]  then "Creó un nuevo producto"
    in [ "admin/products", "update" ]  then "Actualizó el producto ##{id}"
    in [ "admin/products", "destroy" ] then "Eliminó el producto ##{id}"
    in [ "admin/production_orders", "start" ]    then "Inició la orden de producción ##{id}"
    in [ "admin/production_orders", "complete" ] then "Completó la orden de producción ##{id}"
    in [ "admin/production_orders", "update" ]   then "Actualizó la orden de producción ##{id}"
    in [ "admin/appointments", "descargar_informe" ] then nil
    in [ "admin/dashboard", * ]        then nil  # admin dashboard views aren't mutations
    in [ "user_dashboards", * ]        then nil
    in [ "pages", * ]                  then nil
    in [ "contacts", "create" ]        then "Envió un mensaje de contacto"
    in [ "notifications", * ]          then nil
    else
      a.in?(%w[create update destroy]) ? "Acción #{a} en #{c}" : nil
    end
  end

  def find_session
    if (session_id = cookies.signed[:session_id])
      sess = Session.active.find_by(id: session_id)
      if sess
        if sess.updated_at < 2.days.ago
          terminate_session
          return nil
        end
        sess.touch
        return sess
      end
    end
    nil
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    stored = session.delete(:return_to_after_authenticating)
    if stored.present?
      begin
        uri = URI.parse(stored)
        path = uri.path
        login_paths = [ new_session_path, new_session_url ].compact.map(&:to_s)
        return root_path if login_paths.include?(path) || login_paths.include?(stored)
      rescue => _e
        return root_path
      end
    end

    stored || root_path
  end

  def log_event(description)
    sess = Current.session
    return unless sess
    entry = {
      description: description,
      url: request.original_url,
      method: request.method,
      controller: params[:controller],
      action: params[:action],
      visited_at: Time.current.iso8601
    }
    sess.update_column(:activity_log, (sess.activity_log || []) + [ entry ])
  end

  def start_new_session_for(user)
    previous_status = user[:status] || User::STATUSES[:disponible]
    user.update_columns(status: User::STATUSES[:disponible], last_active_at: Time.current)
    user.sessions.create!(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      user_name: "#{user.first_name} #{user.last_name}",
      user_status: previous_status
    ).tap do |new_session|
      cookies.signed[:session_id] = {
        value: new_session.id,
        httponly: true,
        same_site: :lax
      }
      Current.session = new_session
      Current.user = user
    end
  end

  def terminate_session
    user = Current.user
    session_id = cookies.signed[:session_id]
    if session_id
      Session.find_by(id: session_id)&.update!(terminated_at: Time.current)
    end
    if user && session_id && user.sessions.active.where.not(id: session_id).empty?
      user.update_column(:status, User::STATUSES[:desconectado])
    end
    cookies.delete(:session_id)
    Current.session = nil
    Current.user = nil
  end
end
