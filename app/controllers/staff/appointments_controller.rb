module Staff
  class AppointmentsController < Staff::BaseController
    skip_before_action :require_staff!
    before_action :authorize_appointment!, except: [ :buscar_pacientes ]

    def index
      @appointments = Appointment.includes(:user, :branch, :medico, :estudio).order(starts_at: :desc)
      if is_paciente?
        @appointments = @appointments.where(user_id: current_user.id)
      elsif is_medico?
        @appointments = @appointments.where(medico_id: current_user.id)
      end
      if params[:branch_id].present?
        @appointments = @appointments.where(branch_id: params[:branch_id])
      end
      if params[:status].present? && Appointment.statuses.keys.include?(params[:status])
        @appointments = @appointments.where(status: Appointment.statuses[params[:status]])
      end
      if params[:date].present?
        begin
          date = Date.parse(params[:date])
          @appointments = @appointments.by_date(date)
        rescue ArgumentError
        end
      end
      @branches = Branch.where(enabled: true).order(:name)
    end

    def show
      @appointment = Appointment.includes(:user, :branch, :medico, :estudio).find(params[:id])
    end

    def new
      @appointment = Appointment.new
      @pacientes = User.where(role: User.roles[:paciente]).order(:first_name)
      @medicos = User.where(role: User.roles[:medico]).order(:first_name)
      @branches = Branch.where(enabled: true).order(:name)
    end

    def create
      @appointment = Appointment.new(appointment_params)
      if @appointment.save
        redirect_to staff_appointments_path, notice: "Turno agendado correctamente."
      else
        @pacientes = User.where(role: User.roles[:paciente]).order(:first_name)
        @medicos = User.where(role: User.roles[:medico]).order(:first_name)
        @branches = Branch.where(enabled: true).order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @appointment = Appointment.find(params[:id])
      @pacientes = User.where(role: User.roles[:paciente]).order(:first_name)
      @medicos = User.where(role: User.roles[:medico]).order(:first_name)
      @branches = Branch.where(enabled: true).order(:name)
    end

    def update
      @appointment = Appointment.find(params[:id])
      if @appointment.update(appointment_params)
        redirect_to staff_appointment_path(@appointment), notice: "Turno actualizado correctamente."
      else
        @pacientes = User.where(role: User.roles[:paciente]).order(:first_name)
        @medicos = User.where(role: User.roles[:medico]).order(:first_name)
        @branches = Branch.where(enabled: true).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @appointment = Appointment.find(params[:id])
      @appointment.destroy
      redirect_to staff_appointments_path, status: :see_other, notice: "Turno eliminado correctamente."
    end

    def confirm
      @appointment = Appointment.find(params[:id])
      @appointment.update(status: :confirmed)
      redirect_to staff_appointment_path(@appointment), notice: "Turno confirmado."
    end

    def cancel
      @appointment = Appointment.find(params[:id])
      @appointment.update(status: :cancelled)
      redirect_to staff_appointments_path, notice: "Turno cancelado."
    end

    def buscar_pacientes
      pacientes = User.where(role: User.roles[:paciente])
                      .where("first_name ILIKE :q OR last_name ILIKE :q OR ci ILIKE :q", q: "%#{params[:q]}%")
                      .order(:first_name).limit(20)
      render json: pacientes.map { |p|
        { id: p.id, first_name: p.first_name, last_name: p.last_name, ci: p.ci, email: p.email_address, phone: p.phone_number }
      }
    end

    private

    def appointment_params
      params.require(:appointment).permit(:user_id, :estudio_id, :medico_id, :branch_id, :title, :starts_at, :ends_at, :status, :notes)
    end

    def authorize_appointment!(record = nil)
      policy = AppointmentPolicy.new(current_user, record || @appointment || Appointment.new)
      action = action_name.to_sym
      unless policy.public_send("#{action}?")
        redirect_to root_path, alert: "No tienes permisos para acceder aquí."
      end
    end
  end
end
