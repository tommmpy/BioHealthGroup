class Estudio < ApplicationRecord
  audited
  belongs_to :user      # El Paciente
  belongs_to :branch    # La Sucursal

  before_validation :calcular_cantidad_productos
  # Opcional: Relación con el médico (que también es un User)
  belongs_to :medico, class_name: "User", optional: true

  # Definición de Estados
  enum :estado, { pendiente: 0, en_progreso: 1, finalizado: 2 }, default: :pendiente

  def self.ransackable_attributes(auth_object = nil)
    %w[nombre_completo created_at fecha_estudio estado cantidad_productos]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user branch medico]
  end

  # Cantidad de productos se calcula automáticamente antes de validar


  # Validaciones
  validates :nombre_completo, :tipo_producto, :fecha_estudio, presence: true
  validates :cantidad_productos, numericality: { greater_than_or_equal_to: 1 }

  # No permitir marcar como finalizado si no existe metar_paciente
  validate :metar_paciente_present_if_finalizado

  # Tipos de productos permitidos (para usar en el formulario)
  PRODUCTOS_PERMITIDOS = [
    "Plantar de uso diario",
    "Plantar de uso deportivo",
    "Plantar de niño",
    "Plantar adicional"
  ]

  # Métodos de ayuda para obtener datos del Paciente (User)
  def ci_paciente
    user&.ci
  end

  def contacto_root_paciente
    user&.contacto_root
  end

  private

  def calcular_cantidad_productos
    if tipo_producto.is_a?(Array)
      self.cantidad_productos = tipo_producto.reject(&:blank?).size
    else
      self.cantidad_productos = 0
    end
  end

  def metar_paciente_present_if_finalizado
    # Cuando el estado sea finalizado, requerimos metar_paciente presente
    # `estado` es provisto por el enum y devuelve la clave como string (ej: 'finalizado')
    is_finalizado = if respond_to?(:estado)
      estado.to_s == "finalizado"
    else
      # Fallback: compare raw value against enum mapping
      Estudio.respond_to?(:estados) && estado_before_type_cast == Estudio.estados["finalizado"]
    end

    if is_finalizado && metar_paciente.blank?
      errors.add(:metar_paciente, "es obligatorio para marcar el estudio como finalizado")
    end
  end
end
