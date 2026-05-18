class EmptyStateComponent < ApplicationComponent
  def initialize(title:, description: nil, icon: nil)
    @title = title
    @description = description
    @icon = icon
  end

  def call
    content_tag :div, class: "flex flex-col items-center justify-center py-16 px-4 text-center" do
      concat icon_tag if @icon
      concat content_tag(:h3, @title, class: "text-xl font-bold text-white mb-2")
      concat content_tag(:p, @description, class: "text-gray-500 text-sm max-w-md") if @description
      concat content_tag(:div, class: "mt-6") { content } if content?
    end
  end

  private

  def icon_tag
    content_tag :div, class: "w-16 h-16 rounded-2xl bg-gradient-to-br from-orange-500/20 to-orange-600/20 border border-orange-500/10 flex items-center justify-center mb-6" do
      tag.svg class: "w-8 h-8 text-orange-500", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
        concat tag.path("stroke-linecap" => "round", "stroke-linejoin" => "round", "stroke-width" => "1.5", "d" => @icon)
      end
    end
  end
end
