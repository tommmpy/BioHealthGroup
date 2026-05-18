module Admin
  class TestimonialsController < Admin::BaseController
    before_action :require_admin!, except: [ :index, :show ]

    def index
      @testimonials = Testimonial.all.order(:sort_order)
    end

    def show
      @testimonial = Testimonial.find(params[:id])
    end

    def new
      @testimonial = Testimonial.new
    end

    def create
      @testimonial = Testimonial.new(testimonial_params)
      if @testimonial.save
        redirect_to admin_testimonials_path, notice: "Testimonio creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @testimonial = Testimonial.find(params[:id])
    end

    def update
      @testimonial = Testimonial.find(params[:id])
      if @testimonial.update(testimonial_params)
        redirect_to admin_testimonials_path, notice: "Testimonio actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @testimonial = Testimonial.find(params[:id])
      @testimonial.destroy
      redirect_to admin_testimonials_path, notice: "Testimonio eliminado."
    end

    private

    def testimonial_params
      params.require(:testimonial).permit(:author_name, :author_role, :content, :sort_order, :active, :avatar)
    end
  end
end
