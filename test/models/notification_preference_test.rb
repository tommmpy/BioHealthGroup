require "test_helper"

class NotificationPreferenceTest < ActiveSupport::TestCase
  test "belongs to user" do
    pref = notification_preferences(:one)
    assert_instance_of User, pref.user
  end

  test "default values are set correctly via fixture" do
    pref = notification_preferences(:one)
    assert pref.email_notifications
    assert pref.in_app_notifications
    assert pref.reminder_estudios
    assert pref.reminder_appointments
    assert_not pref.marketing_emails
  end

  test "scope receives_email" do
    assert_includes NotificationPreference.receives_email, notification_preferences(:one)
    pref = notification_preferences(:one)
    pref.update!(email_notifications: false)
    assert_not_includes NotificationPreference.receives_email, pref
  end

  test "scope receives_in_app" do
    assert_includes NotificationPreference.receives_in_app, notification_preferences(:one)
  end

  test "scope remembers_estudios" do
    assert_includes NotificationPreference.remembers_estudios, notification_preferences(:one)
  end

  test "scope remembers_appointments" do
    assert_includes NotificationPreference.remembers_appointments, notification_preferences(:one)
  end

  test "scope receives_marketing" do
    assert_empty NotificationPreference.receives_marketing
    pref = notification_preferences(:one)
    pref.update!(marketing_emails: true)
    assert_includes NotificationPreference.receives_marketing, pref
  end

  test "auto-creates notification_preference on user create" do
    user = User.create!(
      email_address: "nuevo@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Nuevo",
      last_name: "Test",
      ci: "99999999",
      phone_number: "099999999",
      address: "Calle 999",
      branch: branches(:one),
      user_type: :persona,
      birthday: 25.years.ago.to_date
    )
    assert_not_nil user.notification_preference
    assert user.notification_preference.email_notifications
    assert user.notification_preference.in_app_notifications
    assert_not user.notification_preference.marketing_emails
  end
end
