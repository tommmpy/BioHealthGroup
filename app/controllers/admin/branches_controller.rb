module Admin
  class BranchesController < Admin::BaseController
    skip_before_action :require_staff!, only: [ :index ]

    def index
      @branches = Branch.left_joins(:users)
                        .group("branches.id")
                        .select("branches.*, COUNT(users.id) AS users_count")

      if params[:status].present?
        @branches = @branches.where(branches: { enabled: params[:status] == "enabled" })
      end

      if params[:query].present?
        search_query = "%#{params[:query].downcase}%"
        @branches = @branches.where(
          "LOWER(branches.name) LIKE ? OR LOWER(branches.address) LIKE ? OR LOWER(branches.phone) LIKE ?",
          search_query, search_query, search_query
        )
      end

      @branch_coordinates = {}
      @branches.each { |b| @branch_coordinates[b.id] = Branches::Geocoder.coordinates_for(b.address) }
    end

    def show
      @branch = Branch.find(params[:id])
    end

    def new
      @branch = Branch.new
    end

    def create
      @branch = Branch.new(branch_params)
      if @branch.save
        redirect_to admin_branches_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @branch = Branch.find(params[:id])
    end

    def update
      @branch = Branch.find(params[:id])
      if @branch.update(branch_params)
        redirect_to admin_branch_path(@branch), notice: "Sede actualizada correctamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @branch = Branch.find(params[:id])
      @branch.destroy
      redirect_to admin_branches_path, status: :see_other
    end

    def toggle_status
      unless is_administrador? || is_recepcionista?
        return redirect_to admin_branches_path, alert: "No tienes permisos para esto."
      end

      @branch = Branch.find(params[:id])

      if @branch.update(enabled: !@branch.enabled)
        redirect_to admin_branches_path, notice: "La sede #{@branch.name} ha sido actualizada."
      else
        redirect_to admin_branches_path, alert: "No se pudo actualizar el estado."
      end
    end

    private

    def branch_params
      params.require(:branch).permit(:name, :address, :phone, :enabled)
    end
  end
end
