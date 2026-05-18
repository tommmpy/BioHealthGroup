module Admin
  class ActivitiesController < Admin::BaseController
    before_action :require_admin!

    def index
      @sessions = Session.where("jsonb_array_length(activity_log) > 0")
                         .includes(:user)
                         .order(updated_at: :desc)
                         .limit(100)
    end
  end
end
