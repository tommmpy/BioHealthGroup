require "test_helper"

class AppointmentReminderJobTest < ActiveJob::TestCase
  test "sends reminder for confirmed appointments starting in ~24 hours" do
    appointment = Appointment.create!(
      user: users(:one),
      branch: branches(:one),
      title: "Cita recordatorio",
      starts_at: 24.hours.from_now,
      ends_at: 25.hours.from_now,
      status: :confirmed
    )

    assert_difference -> { Notification.where(kind: "appointment_reminder").count }, 1 do
      AppointmentReminderJob.perform_now
    end

    notification = Notification.where(kind: "appointment_reminder").last
    assert_equal appointment, notification.notifiable
    assert_equal users(:one), notification.user
  end

  test "skips pending appointments" do
    Appointment.create!(
      user: users(:one),
      branch: branches(:one),
      title: "Cita pendiente",
      starts_at: 24.hours.from_now,
      ends_at: 25.hours.from_now,
      status: :pending
    )

    assert_no_difference -> { Notification.where(kind: "appointment_reminder").count } do
      AppointmentReminderJob.perform_now
    end
  end

  test "skips appointments outside the 24-hour window" do
    Appointment.create!(
      user: users(:one),
      branch: branches(:one),
      title: "Cita lejana",
      starts_at: 48.hours.from_now,
      ends_at: 49.hours.from_now,
      status: :confirmed
    )

    assert_no_difference -> { Notification.where(kind: "appointment_reminder").count } do
      AppointmentReminderJob.perform_now
    end
  end

  test "skips appointment when user notification_preference has reminder_appointments disabled" do
    users(:one).notification_preference.update!(reminder_appointments: false)

    Appointment.create!(
      user: users(:one),
      branch: branches(:one),
      title: "Cita sin recordatorio",
      starts_at: 24.hours.from_now,
      ends_at: 25.hours.from_now,
      status: :confirmed
    )

    assert_no_difference -> { Notification.where(kind: "appointment_reminder").count } do
      AppointmentReminderJob.perform_now
    end
  end
end
