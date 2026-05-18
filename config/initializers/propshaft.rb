# Configure Propshaft asset loading
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "stylesheets", "base")
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "stylesheets", "utilities")
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "tailwind")
