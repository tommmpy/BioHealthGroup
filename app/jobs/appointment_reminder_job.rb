class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform
    Appointment.confirmed
               .where(starts_at: 23.hours.from_now..25.hours.from_now)
               .find_each(batch_size: 100) do |appointment|
      pref = appointment.user.notification_preference
      next unless pref&.reminder_appointments?
      next unless pref.email_notifications? || pref.in_app_notifications?

      NotificationService.new(
        kind: "appointment_reminder",
        title: "Recordatorio de cita",
        user: appointment.user,
        body: "Recordatorio: tienes una cita «#{appointment.title}» mañana a las #{appointment.starts_at.strftime('%H:%M')}.",
        notifiable: appointment
      ).call
    end
  end
end
