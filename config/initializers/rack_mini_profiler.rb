if Rails.env.development?
  require "rack-mini-profiler"

  Rack::MiniProfiler.config.position = "bottom-left"
  Rack::MiniProfiler.config.start_hidden = true
  Rack::MiniProfiler.config.toggle_shortcut = "Alt+P"
end
