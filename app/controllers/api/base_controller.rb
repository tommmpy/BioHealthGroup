module Api
  class BaseController < ApplicationController
    skip_before_action :track_activity

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "No encontrado" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end

    private

    def request_authentication
      render json: { error: "Autenticación requerida" }, status: :unauthorized
    end

    def find_session
      session_id = cookies.signed[:session_id]
      return nil unless session_id

      sess = Session.active.find_by(id: session_id)
      return nil unless sess

      if sess.updated_at < 2.days.ago
        terminate_session
        return nil
      end

      sess.touch
      sess
    end
  end
end
