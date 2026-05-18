class CardComponent < ApplicationComponent
  def initialize(extra_classes: "")
    @extra_classes = extra_classes
  end

  def call
    content_tag :div,
      class: "bg-black/80 backdrop-blur-xl border border-white/10 rounded-2xl p-6 lg:p-8 relative transition-all duration-300 hover:border-orange-500/20 #{@extra_classes}",
      style: "box-shadow: 0 0 30px rgba(255,107,0,0.03), inset 0 1px 0 rgba(255,255,255,0.05);" do
      concat content_tag(:div, "", class: "absolute inset-0 bg-gradient-to-b from-orange-500/3 to-transparent rounded-2xl -z-10")
      concat content if content?
    end
  end
end
