# frozen_string_literal: true

Lograge.define_singleton_method(:attach_to_action_cable) do
  # Skip ActionCable attachment to avoid premature load hook warnings in Rails 8
end

Lograge.define_singleton_method(:keep_original_rails_log) do
  return if Lograge.application.config.lograge.keep_original_rails_log

  require "lograge/rails_ext/rack/logger"

  Lograge.remove_existing_log_subscriptions
end
