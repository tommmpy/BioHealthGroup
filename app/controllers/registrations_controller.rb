class RegistrationsController < ApplicationController
  # Permitimos que usuarios no logueados vean esta página
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(user_type: :persona))
    @user.skip_contacto_root = true
    if @user.save
      start_new_session_for @user
      WelcomeMailer.welcome(@user).deliver_now
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
