module Api
  class SessionsController < BaseController
    allow_unauthenticated_access only: :create

    rate_limit to: 10, within: 3.minutes, only: :create,
      key: -> { [ request.remote_ip, params[:email_address]&.strip&.downcase ].join(":") },
      with: -> { render json: { error: "Demasiados intentos" }, status: :too_many_requests }

    def create
      if user = User.authenticate_by(params.permit(:email_address, :password))
        @session = start_new_session_for(user)
        @user = user
        log_event("Inició sesión (API)")
        render :show, status: :created
      else
        render json: { error: "Email o contraseña incorrectos" }, status: :unauthorized
      end
    end

    def destroy
      terminate_session
      render json: { message: "Sesión cerrada correctamente" }, status: :ok
    end
  end
end
