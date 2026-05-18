class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create choose recover force_new ]

  rate_limit to: 10, within: 3.minutes, only: :create,
    key: -> { [ request.remote_ip, params[:email_address]&.strip&.downcase ].join(":") },
    with: -> {
      respond_to do |format|
        format.html { redirect_to new_session_url, alert: "Demasiados intentos. Esperá 3 minutos." }
        format.json { render json: { error: "Demasiados intentos" }, status: :too_many_requests }
      end
    }

  def new
    redirect_to root_path if authenticated?
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.sessions.any?
        session[:pending_user_id] = user.id
        redirect_to choose_session_path
      else
        start_new_session_for user
        log_event("Inició sesión")
        dest = after_authentication_url
        if dest.to_s.include?(new_session_path)
          dest = root_path
        end
        redirect_to dest, notice: "Bienvenido de nuevo."
      end
    else
      redirect_to new_session_path, alert: "Email o contraseña incorrectos."
    end
  end

  def choose
    @user = User.find_by(id: session[:pending_user_id])
    redirect_to new_session_path, alert: "No hay sesión pendiente." unless @user
  end

  def recover
    user = User.find_by(id: session[:pending_user_id])
    unless user
      redirect_to new_session_path, alert: "No hay sesión pendiente."
      return
    end

    existing = user.sessions.where.not(terminated_at: nil).order(terminated_at: :desc).first
    unless existing
      redirect_to new_session_path, alert: "No hay sesiones para recuperar."
      return
    end

    session.delete(:pending_user_id)
    existing.update!(terminated_at: nil)
    status = existing.user_status == User::STATUSES[:desconectado] ? User::STATUSES[:disponible] : existing.user_status
    user.update_columns(status: status, last_active_at: Time.current)
    cookies.signed[:session_id] = { value: existing.id, httponly: true, same_site: :lax }
    Current.session = existing
    Current.user = user
    log_event("Recuperó una sesión anterior")
    redirect_to (existing.last_url.presence || root_path), notice: "Sesión recuperada."
  end

  def force_new
    user = User.find_by(id: session[:pending_user_id])
    unless user
      redirect_to new_session_path, alert: "No hay sesión pendiente."
      return
    end

    session.delete(:pending_user_id)
    user.sessions.active.update_all(terminated_at: Time.current)
    start_new_session_for user
    log_event("Inició sesión (nueva)")
    redirect_to root_path, notice: "Nueva sesión iniciada."
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Sesión cerrada correctamente."
  end
end
