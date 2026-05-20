module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :historial ]
    before_action :require_admin!

    def index
      @users = User.includes(:branch, :estudios).order(:role, :first_name)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      @user.role = permitted_role if params[:user][:role].present?
      @user.password = generate_random_password
      if @user.save
        PasswordsMailer.reset(@user).deliver_now
        redirect_to admin_users_path, notice: "Usuario creado. Se le envió un email para que establezca su contraseña."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def historial
      @estudios = @user.estudios.includes(:branch, :medico).order(fecha_estudio: :desc)
    end

    def edit
    end

    def update
      @user.role = permitted_role if params[:user][:role].present?
      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "No puedes eliminar tu propia cuenta."
      elsif @user.destroy
        redirect_to admin_users_path, notice: "Usuario eliminado correctamente.", status: :see_other
      else
        redirect_to admin_users_path, alert: "Error al intentar eliminar.", status: :see_other
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def generate_random_password
      required = [ *"A".."Z" ].sample + [ *"a".."z" ].sample + [ *"0".."9" ].sample
      (required + SecureRandom.alphanumeric(13)).chars.shuffle.join
    end

    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email_address, :ci,
        :phone_number, :address, :branch_id,
        :user_type, :contacto_root,
        :birthday
      )
    end
    def permitted_role
      role = params[:user][:role].to_s.to_i
      User::ROLES.value?(role) ? role : nil
    end
  end
end
