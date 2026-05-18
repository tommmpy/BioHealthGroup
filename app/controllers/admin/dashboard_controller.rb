module Admin
  class DashboardController < Admin::BaseController
    skip_before_action :require_staff!, only: [ :index ]

    def index
      @total_users = User.count
      @recent_users = User.order(created_at: :desc).limit(5)
      @top_branches = Branch.joins(:users)
                            .group("branches.id")
                            .select("branches.*, COUNT(users.id) as user_count")
                            .order("user_count DESC")
                            .limit(3)
      @users_by_day = User.group_by_day(:created_at, range: 30.days.ago..Time.current).count
      @estudios_by_status = Estudio.group(:estado).count
      @estudios_by_day = Estudio.where(created_at: 30.days.ago..Time.current)
                                .group_by_day(:created_at).count

      @pending_orders = ProductionOrder.pending.count
      @low_stock_products = Product.active.where("stock_quantity <= ?", 5).order(:stock_quantity)

      @recent_activities = Session.where("jsonb_array_length(activity_log) > 0")
                                  .includes(:user)
                                  .order(updated_at: :desc)
                                  .limit(20)
                                  .flat_map { |s|
                                    (s.activity_log || []).map { |e|
                                      e.merge("user_name" => s.user_name, "session_id" => s.id)
                                    }
                                  }
                                  .sort_by { |e| e["visited_at"] }
                                  .reverse
                                  .first(10)
    end
  end
end
