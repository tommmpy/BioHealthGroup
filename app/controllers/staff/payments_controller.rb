module Staff
  class PaymentsController < Staff::BaseController
    before_action :set_invoice

    def index
      @payments = @invoice.payments.order(created_at: :desc)
    end

    def create
      @payment = @invoice.payments.new(payment_params)
      @payment.paid_at ||= Time.current
      if @payment.save
        redirect_to staff_invoice_path(@invoice), notice: "Pago registrado correctamente."
      else
        redirect_to staff_invoice_path(@invoice), alert: "Error al registrar el pago: #{@payment.errors.full_messages.join(', ')}"
      end
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:invoice_id])
    end

    def payment_params
      params.require(:payment).permit(:amount, :payment_method, :reference, :paid_at, :notes)
    end
  end
end
