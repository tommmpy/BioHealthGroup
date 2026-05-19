# frozen_string_literal: true

Lograge.module_eval do
  private

  def keep_original_rails_log
    return if lograge_config.keep_original_rails_log

    require "lograge/rails_ext/rack/logger"

    Lograge.remove_existing_log_subscriptions
  end

  def attach_to_action_cable
    # Skip ActionCable attachment to avoid premature load hook warnings in Rails 8
  end
end
