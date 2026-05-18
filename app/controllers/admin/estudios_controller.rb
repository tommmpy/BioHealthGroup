require "csv"

module Admin
  class EstudiosController < Admin::BaseController
    skip_before_action :require_staff!
    before_action :authorize_estudio!, except: [ :buscar_pacientes ]

    def index
      @q = Estudio.includes(:user, :branch, :medico).ransack(params[:q])
      @estudios = @q.result.order(fecha_estudio: :desc)

      if is_paciente?
        @estudios = @estudios.where(user_id: current_user.id)
      elsif params[:user_id].present?
        @estudios = @estudios.where(user_id: params[:user_id])
      elsif is_medico?
        pendiente = Estudio.estados["pendiente"]
        @estudios = @estudios.where(
          "(medico_id = ?) OR (branch_id = ? AND estado = ?)",
          current_user.id, current_user.branch_id, pendiente
        )
      end

      respond_to do |format|
        format.html
        format.csv do
          headers = [ "ID", "Nombre Completo", "CI", "Estado", "Fecha Estudio", "Sucursal", "Médico", "Cantidad Productos", "Tipo Producto", "Creado" ]

          csv_data = CSV.generate(headers: true) do |csv|
            csv << headers
            @estudios.each do |e|
              csv << [
                e.id,
                e.nombre_completo,
                e.user&.ci,
                e.estado.humanize,
                e.fecha_estudio.strftime("%d/%m/%Y %H:%M"),
                e.branch&.name,
                e.medico.present? ? "#{e.medico.first_name} #{e.medico.last_name}" : "",
                e.cantidad_productos,
                Array(e.tipo_producto).join(", "),
                e.created_at.strftime("%d/%m/%Y %H:%M")
              ]
            end
          end

          send_data csv_data, filename: "estudios_#{Date.current}.csv"
        end
      end
    end

    def show
      @estudio = Estudio.find(params[:id])
    end

    def new
      @estudio = Estudio.new
    end

    def buscar_pacientes
      pacientes = Estudios::PatientFinder.call(query: params[:q])
      render json: pacientes.map { |p|
        {
          id: p.id,
          first_name: p.first_name,
          last_name: p.last_name,
          ci: p.ci,
          email: p.email_address,
          phone: p.phone_number
        }
      }
    end

    def create
      @estudio = Estudio.new(estudio_params)

      if @estudio.save
        redirect_to admin_estudios_path, notice: "Estudio agendado correctamente."
      else
        @pacientes = User.where(role: User.roles[:paciente])
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @estudio = Estudio.find(params[:id])
      @pacientes = User.where(role: User.roles[:paciente])
    end

    def update
      @estudio = Estudio.find(params[:id])
      if @estudio.update(estudio_update_params)
        if @estudio.metar_paciente.present? && @estudio.en_progreso?
          Estudios::Workflow.call(@estudio, :finalizar)
        end
        redirect_to admin_estudio_path(@estudio), notice: "Estudio actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @estudio = Estudio.find(params[:id])
      @estudio.destroy
      redirect_to admin_estudios_path, status: :see_other
    end

    def iniciar
      @estudio = Estudio.find(params[:id])
      result = Estudios::Workflow.call(@estudio, :iniciar, current_user: current_user)
      redirect_to admin_estudios_path
    end

    def finalizar
      @estudio = Estudio.find(params[:id])
      result = Estudios::Workflow.call(@estudio, :finalizar)
      if result[:success]
        redirect_to admin_estudios_path, notice: result[:notice]
      else
        redirect_to result[:alert] ? edit_admin_estudio_path(@estudio) : admin_estudios_path, alert: result[:alert]
      end
    end

    def descargar_informe
      @estudio = Estudio.find(params[:id])

      pdf = Prawn::Document.new(page_size: "A4", margin: [ 50, 50, 50, 50 ])

      pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width, height: 80) do
        pdf.text "BIOHEALTH GROUP", size: 22, style: :bold, color: "FF6B00"
        pdf.text "Informe Clínico de Podología", size: 12, color: "666666"

        pdf.move_cursor_to 80
        pdf.text "Estudio N°: #{@estudio.id}", align: :right, style: :bold
        pdf.text "Fecha: #{@estudio.fecha_estudio.strftime('%d/%m/%Y')}", align: :right
        pdf.text "Estado: #{@estudio.estado.humanize.upcase}", align: :right, color: "00A3FF"
      end

      pdf.stroke_horizontal_rule
      pdf.move_down 30

      pdf.fill_color "F2F2F2"
      pdf.fill_and_stroke_rectangle [ 0, pdf.cursor ], pdf.bounds.width, 20
      pdf.fill_color "000000"
      pdf.move_down 5
      pdf.text "  DATOS DEL PACIENTE", style: :bold, size: 10
      pdf.move_down 15

      pdf.indent(10) do
        pdf.column_box([ 0, pdf.cursor ], columns: 2, width: pdf.bounds.width) do
          pdf.text "Nombre: #{@estudio.nombre_completo}", style: :bold
          pdf.text "Cédula de Identidad: #{@estudio.user&.ci}"
          pdf.move_down 10
          pdf.text "Sucursal: #{@estudio.branch.name}"
          pdf.text "Médico: #{@estudio.medico&.first_name || 'No asignado'} #{@estudio.medico&.last_name}"
        end
      end

      pdf.move_down 40

      pdf.text "RESULTADOS DEL ESTUDIO", style: :bold, size: 12, color: "FF6B00"
      pdf.move_down 10

      pdf.canvas do
        pdf.fill_color "F9F9F9"
        pdf.fill_rectangle [ 50, 480 ], 500, 80
      end

      pdf.fill_color "000000"
      pdf.move_down 20
      pdf.font "Courier" do
        val_metar = @estudio.metar_paciente.presence || "PENDIENTE DE CARGA"
        pdf.text val_metar, size: 32, style: :bold, align: :center, character_spacing: 2
      end
      pdf.move_down 30

      pdf.text "PRODUCTOS SOLICITADOS", style: :bold, size: 12
      pdf.move_down 10

      productos = @estudio.tipo_producto.is_a?(Array) ? @estudio.tipo_producto.join(", ") : @estudio.tipo_producto
      pdf.text "• Tipos: #{productos}", size: 11
      pdf.text "• Cantidad total: #{@estudio.cantidad_productos}", size: 11

      pdf.number_pages "BioHealth Group - Documento oficial generado el #{Time.now.strftime('%d/%m/%Y %H:%M')} - Página <page> de <total>",
        at: [ pdf.bounds.left, -20 ],
        size: 8,
        color: "999999"

      send_data pdf.render,
        filename: "informe_#{@estudio.nombre_completo.parameterize}_#{@estudio.id}.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private

    def estudio_params
      params.require(:estudio).permit(
        :user_id, :nombre_completo, :cantidad_productos,
        :fecha_estudio, :branch_id, :medico_id, tipo_producto: []
      ).tap do |whitelisted|
        whitelisted[:tipo_producto] = whitelisted[:tipo_producto].reject(&:blank?) if whitelisted[:tipo_producto]
      end
    end

    def estudio_update_params
      params.require(:estudio).permit(:metar_paciente, :nombre_completo, :fecha_estudio, :branch_id, :medico_id, tipo_producto: [], files: [])
    end

    def authorize_estudio!(record = nil)
      policy = EstudioPolicy.new(current_user, record || @estudio || Estudio.new)
      action = action_name.to_sym
      unless policy.public_send("#{action}?")
        redirect_to root_path, alert: "No tienes permisos para acceder aquí."
      end
    end
  end
end
