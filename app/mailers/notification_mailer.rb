class NotificationMailer < ApplicationMailer
  default from: "notificaciones@biohealthgroup.com.uy"

  def notification_email(notification)
    @notification = notification
    @user = notification.user

    mail(
      to: @user.email_address,
      subject: "BioHealthGroup - #{notification.title}"
    )
  end
end
