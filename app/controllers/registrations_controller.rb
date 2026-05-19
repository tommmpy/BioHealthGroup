class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 30.minutes, only: :create,
    with: -> { redirect_to new_registration_path, alert: "Demasiados registros desde esta IP. Intenta de nuevo más tarde." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(user_type: :persona))
    @user.skip_contacto_root = true
    if @user.save
      start_new_session_for @user
      WelcomeMailer.welcome(@user).deliver_later
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # Agregamos :branch_id a la lista
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
