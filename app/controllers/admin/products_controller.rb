module Admin
  class ProductsController < Admin::BaseController
    before_action :require_admin!, except: [ :index ]
    before_action :set_product, only: [ :show, :edit, :update, :destroy ]

    def index
      @q = Product.includes(:branch).ransack(params[:q])
      @products = @q.result.order(:name)
    end

    def show
    end

    def new
      @product = Product.new
    end

    def edit
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_products_path, notice: "Producto creado correctamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Producto actualizado correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Producto eliminado.", status: :see_other
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :category, :unit_price, :stock_quantity, :branch_id, :active)
    end
  end
end
