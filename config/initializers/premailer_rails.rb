Rails.application.config.after_initialize do
  Premailer::Rails.config.merge!(preserve_styles: true, remove_ids: true)
end
