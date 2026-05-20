module Staff
  class ProductionOrdersController < Staff::BaseController
    before_action :set_order, only: [ :show, :update, :start, :complete, :complete_task ]

    def index
      @q = ProductionOrder.includes(estudio: [ :user, :branch, :medico ], assigned_to: {}, production_tasks: {}).ransack(params[:q])
      @production_orders = @q.result.order(created_at: :desc)
      if is_operario? && !is_administrador? && !is_disenador?
        @production_orders = @production_orders.where(assigned_to_id: current_user.id)
      end
    end

    def show
      @tasks = @production_order.production_tasks.ordered
    end

    def update
      if @production_order.update(production_order_params)
        redirect_to staff_production_order_path(@production_order), notice: "Orden actualizada correctamente."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def start
      if @production_order.pending?
        @production_order.update!(status: :in_progress, assigned_to_id: current_user.id)
        @production_order.create_default_tasks!
        redirect_to staff_production_order_path(@production_order), notice: "Orden de producción iniciada."
      else
        redirect_to staff_production_orders_path, alert: "No se puede iniciar una orden en estado #{@production_order.status}."
      end
    end

    def complete_task
      task = @production_order.production_tasks.find(params[:task_id])
      unless task.assignable_by?(current_user)
        redirect_to staff_production_order_path(@production_order), alert: "No tenés permisos para completar esta tarea."
        return
      end
      task.update!(completed: true, completed_at: Time.current, completed_by: current_user)

      if @production_order.all_tasks_completed?
        @production_order.update!(status: :completed, completed_at: Time.current)
        redirect_to staff_production_order_path(@production_order), notice: "Todas las tareas completadas. Producción finalizada."
      else
        redirect_to staff_production_order_path(@production_order), notice: "Tarea '#{task.name}' completada."
      end
    end

    def complete
      if @production_order.in_progress?
        remaining = @production_order.production_tasks.pending.count
        if remaining > 0
          redirect_to staff_production_order_path(@production_order), alert: "Faltan #{remaining} tarea(s) por completar."
        else
          @production_order.update!(status: :completed, completed_at: Time.current)
          redirect_to staff_production_orders_path, notice: "Orden de producción completada."
        end
      else
        redirect_to staff_production_orders_path, alert: "No se puede completar una orden en estado #{@production_order.status}."
      end
    end

    private

    def set_order
      @production_order = ProductionOrder.find(params[:id])
    end

    def production_order_params
      params.require(:production_order).permit(:assigned_to_id, :status, :notes, :due_date)
    end
  end
end
