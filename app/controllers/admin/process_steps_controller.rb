module Admin
  class ProcessStepsController < Admin::BaseController
    before_action :require_admin!, except: [ :index, :show ]

    def index
      @process_steps = ProcessStep.all.order(:step_number)
    end

    def show
      @process_step = ProcessStep.find(params[:id])
    end

    def new
      @process_step = ProcessStep.new
    end

    def create
      @process_step = ProcessStep.new(process_step_params)
      if @process_step.save
        redirect_to admin_process_steps_path, notice: "Paso creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @process_step = ProcessStep.find(params[:id])
    end

    def update
      @process_step = ProcessStep.find(params[:id])
      if @process_step.update(process_step_params)
        redirect_to admin_process_steps_path, notice: "Paso actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @process_step = ProcessStep.find(params[:id])
      @process_step.destroy
      redirect_to admin_process_steps_path, notice: "Paso eliminado."
    end

    private

    def process_step_params
      params.require(:process_step).permit(:step_number, :title, :description, :icon, :active, :image)
    end
  end
end
