Rails.application.config.after_initialize do
  if Rails.env.production? && ActiveRecord::Base.connection.data_source_exists?("branches") && Branch.count == 0
    Rails.logger.info "Database empty — running seeds..."
    load Rails.root.join("db/seeds.rb")
  end
rescue => e
  Rails.logger.warn "Auto-seed skipped: #{e.message}"
end
