module Admin
  class HeroSlidesController < Admin::BaseController
    before_action :require_admin!, except: [ :index, :show ]

    def index
      @hero_slides = HeroSlide.all.order(:sort_order)
    end

    def show
      @hero_slide = HeroSlide.find(params[:id])
    end

    def new
      @hero_slide = HeroSlide.new
    end

    def create
      @hero_slide = HeroSlide.new(hero_slide_params)
      if @hero_slide.save
        redirect_to admin_hero_slides_path, notice: "Slide creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @hero_slide = HeroSlide.find(params[:id])
    end

    def update
      @hero_slide = HeroSlide.find(params[:id])
      if @hero_slide.update(hero_slide_params)
        redirect_to admin_hero_slides_path, notice: "Slide actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @hero_slide = HeroSlide.find(params[:id])
      @hero_slide.destroy
      redirect_to admin_hero_slides_path, notice: "Slide eliminado."
    end

    private

    def hero_slide_params
      params.require(:hero_slide).permit(:title, :subtitle, :cta_text, :cta_link, :sort_order, :active, :image)
    end
  end
end
