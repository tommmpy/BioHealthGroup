class EstudioReminderJob < ApplicationJob
  queue_as :default

  def perform
    Estudio.pendiente
           .where("created_at < ?", 7.days.ago)
           .find_each(batch_size: 100) do |estudio|
      next if Notification.exists?(notifiable: estudio, kind: "estudio_reminder")

      pref = estudio.user.notification_preference
      next unless pref&.reminder_estudios?
      next unless pref.email_notifications? || pref.in_app_notifications?

      NotificationService.new(
        kind: "estudio_reminder",
        title: "Recordatorio: estudio pendiente",
        user: estudio.user,
        body: "Tu estudio «#{estudio.nombre_completo}» fue creado hace más de 7 días y aún está pendiente. Por favor, agendá tu cita.",
        notifiable: estudio
      ).call
    end
  end
end
