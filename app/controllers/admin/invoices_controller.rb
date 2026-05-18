require "prawn"
Prawn::Fonts::AFM.hide_m17n_warning = true

module Admin
  class InvoicesController < Admin::BaseController
    def index
      @q = Invoice.includes(:user, :estudio).ransack(params[:q])
      @invoices = @q.result.order(created_at: :desc)

      if params[:status].present? && Invoice.statuses.key?(params[:status])
        @invoices = @invoices.where(status: Invoice.statuses[params[:status]])
      end

      if params[:from_date].present?
        @invoices = @invoices.where("due_date >= ?", params[:from_date])
      end

      if params[:to_date].present?
        @invoices = @invoices.where("due_date <= ?", params[:to_date])
      end
    end

    def show
      @invoice = Invoice.includes(:user, :estudio, :payments).find(params[:id])
      @payment = @invoice.payments.new
    end

    def new
      @invoice = Invoice.new
    end

    def create
      @invoice = Invoice.new(invoice_params)

      if @invoice.save
        redirect_to admin_invoice_path(@invoice), notice: "Factura creada correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def mark_sent
      @invoice = Invoice.find(params[:id])
      @invoice.update(status: :sent)
      redirect_to admin_invoice_path(@invoice), notice: "Factura marcada como enviada."
    end

    def mark_paid
      @invoice = Invoice.find(params[:id])
      @invoice.update(status: :paid, paid_at: Time.current)
      redirect_to admin_invoice_path(@invoice), notice: "Factura marcada como pagada."
    end

    def download_pdf
      @invoice = Invoice.includes(:user, :estudio, :payments).find(params[:id])

      pdf = Prawn::Document.new(page_size: "A4", margin: [ 40, 40, 40, 40 ])

      pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width, height: 90) do
        pdf.text "BIOHEALTH GROUP", size: 24, style: :bold, color: "FF6B00"
        pdf.text "Factura #{@invoice.invoice_number}", size: 14, color: "666666"
        pdf.move_cursor_to 90
        pdf.text "Fecha de emisión: #{@invoice.created_at.strftime('%d/%m/%Y')}", align: :right, size: 10
        pdf.text "Vencimiento: #{@invoice.due_date.strftime('%d/%m/%Y')}", align: :right, size: 10
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 25

      pdf.text "DATOS DEL PACIENTE", style: :bold, size: 11
      pdf.move_down 8
      pdf.indent(10) do
        pdf.text "Nombre: #{@invoice.user.first_name} #{@invoice.user.last_name}", size: 10
        pdf.text "CI: #{@invoice.user.ci}", size: 10
        pdf.text "Dirección: #{@invoice.user.address}", size: 10
        pdf.text "Teléfono: #{@invoice.user.phone_number}", size: 10
      end

      pdf.move_down 25
      pdf.stroke_horizontal_rule
      pdf.move_down 20

      pdf.text "DETALLE DE FACTURACIÓN", style: :bold, size: 11
      pdf.move_down 10

      pdf.indent(10) do
        pdf.text "DESCRIPCIÓN                                    PRECIO", size: 9, style: :bold
      end
      pdf.move_down 5
      pdf.stroke_horizontal_rule
      pdf.move_down 10

      desc = @invoice.estudio.present? ? "Estudio biomecánico - #{@invoice.estudio.nombre_completo}" : "Servicios profesionales"
      pdf.text desc, size: 10, style: :bold
      pdf.move_up 12
      pdf.text "$ #{@invoice.subtotal}", align: :right, size: 10
      pdf.move_down 5
      pdf.stroke_horizontal_rule
      pdf.move_down 5

      pdf.move_down 15

      pdf.text "Subtotal: $ #{@invoice.subtotal}", align: :right, size: 11
      pdf.text "IVA (#{@invoice.tax_rate}%): $ #{@invoice.tax_amount}", align: :right, size: 11
      pdf.move_down 5
      pdf.text "TOTAL: $ #{@invoice.total}", align: :right, size: 16, style: :bold, color: "FF6B00"

      if @invoice.notes.present?
        pdf.move_down 20
        pdf.stroke_horizontal_rule
        pdf.move_down 10
        pdf.text "NOTAS", style: :bold, size: 10
        pdf.text @invoice.notes, size: 9, color: "666666"
      end

      pdf.number_pages "BioHealth Group - Documento oficial - Página <page> de <total>",
        at: [ pdf.bounds.left, -20 ],
        size: 8,
        color: "999999"

      send_data pdf.render,
        filename: "factura_#{@invoice.invoice_number}.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private

    def invoice_params
      params.require(:invoice).permit(
        :user_id, :estudio_id, :subtotal, :tax_rate, :tax_amount,
        :total, :due_date, :notes
      )
    end
  end
end
