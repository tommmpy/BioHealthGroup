module Admin
  class ProductionOrdersController < Admin::BaseController
    before_action :set_order, only: [ :show, :update, :start, :complete ]

    def index
      @q = ProductionOrder.includes(estudio: [ :user, :branch, :medico ], assigned_to: {}).ransack(params[:q])
      @production_orders = @q.result.order(created_at: :desc)

      if is_operario? && !is_administrador?
        @production_orders = @production_orders.where(assigned_to_id: current_user.id)
      end
    end

    def show
    end

    def update
      if @production_order.update(production_order_params)
        redirect_to admin_production_order_path(@production_order), notice: "Orden actualizada correctamente."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def start
      if @production_order.pending?
        @production_order.update!(status: :in_progress, assigned_to_id: current_user.id)
        redirect_to admin_production_orders_path, notice: "Orden de producción iniciada."
      else
        redirect_to admin_production_orders_path, alert: "No se puede iniciar una orden en estado #{@production_order.status}."
      end
    end

    def complete
      if @production_order.in_progress?
        @production_order.update!(status: :completed, completed_at: Time.current)
        redirect_to admin_production_orders_path, notice: "Orden de producción completada."
      else
        redirect_to admin_production_orders_path, alert: "No se puede completar una orden en estado #{@production_order.status}."
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
