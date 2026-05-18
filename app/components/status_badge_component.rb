class StatusBadgeComponent < ApplicationComponent
  STATUS_CLASSES = {
    "disponible"  => "bg-green-500/10 text-green-400 border-green-500/20",
    "ausente"     => "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
    "no_molestar" => "bg-red-500/10 text-red-400 border-red-500/20",
    "pendiente"   => "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
    "en_progreso" => "bg-blue-500/10 text-blue-400 border-blue-500/20",
    "completado"  => "bg-green-500/10 text-green-400 border-green-500/20",
    "cancelado"   => "bg-red-500/10 text-red-400 border-red-500/20",
    "activa"      => "bg-green-500/10 text-green-400 border-green-500/20",
    "inactiva"    => "bg-gray-500/10 text-gray-400 border-gray-500/20"
  }.freeze

  def initialize(status:, label: nil, size: :sm)
    @status = status.to_s
    @label = label
    @size = size
  end

  def call
    tag.span label_text,
      class: "#{status_class} #{size_class} inline-flex items-center font-bold rounded-full border"
  end

  private

  def label_text
    @label || @status.humanize
  end

  def status_class
    STATUS_CLASSES[@status] || "bg-gray-500/10 text-gray-400 border-gray-500/20"
  end

  def size_class
    @size == :sm ? "text-[10px] px-2.5 py-1" : "text-xs px-3 py-1.5"
  end
end
