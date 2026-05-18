class Current < ActiveSupport::CurrentAttributes
  attribute :session, :user

  class << self
    def user
      super || console_fallback(:user)
    end

    def session
      super || console_fallback(:session)
    end

    private

    def console_fallback(attr)
      return nil unless defined?(Rails::Console) ||
        caller_locations.any? { |l| l.path&.include?("commands/runner") }

      s = Session.recently_active.includes(:user).where.not(user_id: nil).order(updated_at: :desc).first
      return nil unless s

      attr == :session ? s : s.user
    end
  end
end
