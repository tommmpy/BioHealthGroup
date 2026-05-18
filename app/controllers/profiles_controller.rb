class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if params[:user][:status].present?
      key = params[:user][:status].to_s.strip.to_sym
      if User::STATUSES.key?(key)
        int_val = User::STATUSES[key]
        @user.update_column(:status, int_val)
        Current.session&.update_column(:user_status, int_val)
      end
    end
    if @user.update(user_params.except(:status))
      redirect_to profile_path, notice: "Perfil actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_status
    new_status = params[:status].to_s.strip
    if User::STATUSES.key?(new_status.to_sym)
      int_val = User::STATUSES[new_status.to_sym]
      @user.update_column(:status, int_val)
      Current.session&.update_column(:user_status, int_val)
      redirect_back fallback_location: root_path, notice: "Estado actualizado a #{User::STATUS_LABELS[new_status]}."
    else
      head :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    # Verifica que branch_id esté presente aquí:
    permitted = params.require(:user).permit(
      :first_name,
      :last_name,
      :email_address,
      :phone_number,
      :address,
      :branch_id,
      :ci,
      :birthday,
      :contacto_root,
      :status
    )
    if permitted[:status].present?
      permitted[:status] = User::STATUSES[permitted[:status].to_sym]
    end
    permitted
  end
end
