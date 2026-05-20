class NotificationMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM", "noreply@biohealthgroup.uy")

  def notification_email(notification)
    @notification = notification
    @user = notification.user

    mail(
      to: @user.email_address,
      subject: "BioHealthGroup - #{notification.title}"
    )
  end
end
