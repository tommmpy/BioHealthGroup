class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@biohealthgroup.uy")
  layout "mailer"

  after_action :attach_logo

  private

  def attach_logo
    path = Rails.root.join("app/assets/images/logo_bhg_email.png")
    return unless File.exist?(path)

    message.attachments["logo_bhg_email.png"] = File.read(path)
    message.attachments.last["Content-ID"] = "<logo@bhg>"
    message.attachments.last["Content-Disposition"] = "inline"

    alter = message.parts.find { |p| p.content_type.include?("multipart/alternative") }
    message.content_type = "multipart/related" if alter
  end
end
