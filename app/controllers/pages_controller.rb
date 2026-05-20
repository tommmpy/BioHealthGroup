class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    @branches = Branch.where(enabled: true)
    @hero_slides = HeroSlide.active.sorted
    @process_steps = ProcessStep.active.sorted
    @testimonials = Testimonial.active.sorted
  end
end
