class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    ip = request.remote_ip
    key = "reg_rate_limit_#{ip}"
    attempts = Rails.cache.read(key).to_i
    if attempts >= 5
      flash[:alert] = "Demasiados intentos. Intenta de nuevo más tarde."
      return redirect_to new_registration_path
    end
    Rails.cache.write(key, attempts + 1, expires_in: 1.hour)

    @user = User.new(user_params.merge(user_type: :persona))
    @user.skip_contacto_root = true
    if @user.save
      Rails.cache.delete(key)
      start_new_session_for @user
      WelcomeMailer.welcome(@user).deliver_now
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Registration error: #{e.class}: #{e.message}"
    flash[:alert] = "Error al registrarse: #{e.message}"
    redirect_to new_registration_path
  end

  private

  def user_params
    params.require(:user).permit(
      :email_address,
      :password,
      :first_name,
      :last_name,
      :ci,
      :phone_number,
      :address,
      :branch_id,
      :birthday
    )
  end
end
