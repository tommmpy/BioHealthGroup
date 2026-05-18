module Api
  class ProfileController < BaseController
    def show
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update(profile_params)
        render :show, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def notifications
      @notifications = current_user.notifications.recent.includes(:notifiable)
      @pagy, @notifications = pagy(@notifications, limit: 30)
    end

    private

    def profile_params
      params.require(:user).permit(
        :first_name, :last_name, :email_address, :phone_number,
        :address, :ci, :birthday, :contacto_root
      )
    end
  end
end
