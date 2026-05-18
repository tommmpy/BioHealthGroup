require "test_helper"

class EstudioReminderJobTest < ActiveJob::TestCase
  test "sends reminder for pendiente estudios older than 7 days" do
    estudio = Estudio.create!(
      user: users(:one),
      branch: branches(:one),
      nombre_completo: "Estudio viejo",
      tipo_producto: [ "Plantar de uso diario" ],
      cantidad_productos: 1,
      fecha_estudio: 8.days.ago,
      created_at: 8.days.ago,
      estado: :pendiente
    )

    assert_difference -> { Notification.where(kind: "estudio_reminder").count }, 1 do
      EstudioReminderJob.perform_now
    end

    notification = Notification.where(kind: "estudio_reminder").last
    assert_equal estudio, notification.notifiable
    assert_equal users(:one), notification.user
  end

  test "skips estudio that already has a reminder" do
    estudio = Estudio.create!(
      user: users(:one),
      branch: branches(:one),
      nombre_completo: "Estudio con reminder",
      tipo_producto: [ "Plantar de uso diario" ],
      cantidad_productos: 1,
      fecha_estudio: 8.days.ago,
      created_at: 8.days.ago,
      estado: :pendiente
    )

    Notification.create!(
      kind: "estudio_reminder",
      title: "Recordatorio",
      user: users(:one),
      notifiable: estudio
    )

    assert_no_difference -> { Notification.where(kind: "estudio_reminder").count } do
      EstudioReminderJob.perform_now
    end
  end

  test "skips estudio created less than 7 days ago" do
    Estudio.create!(
      user: users(:one),
      branch: branches(:one),
      nombre_completo: "Estudio reciente",
      tipo_producto: [ "Plantar de uso diario" ],
      cantidad_productos: 1,
      fecha_estudio: Time.current,
      estado: :pendiente
    )

    assert_no_difference -> { Notification.where(kind: "estudio_reminder").count } do
      EstudioReminderJob.perform_now
    end
  end

  test "skips estudio when user notification_preference has reminder_estudios disabled" do
    users(:one).notification_preference.update!(reminder_estudios: false)

    Estudio.create!(
      user: users(:one),
      branch: branches(:one),
      nombre_completo: "Estudio sin reminder",
      tipo_producto: [ "Plantar de uso diario" ],
      cantidad_productos: 1,
      fecha_estudio: 8.days.ago,
      created_at: 8.days.ago,
      estado: :pendiente
    )

    assert_no_difference -> { Notification.where(kind: "estudio_reminder").count } do
      EstudioReminderJob.perform_now
    end
  end
end
