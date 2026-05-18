class NotificationPreference < ApplicationRecord
  belongs_to :user

  scope :receives_email, -> { where(email_notifications: true) }
  scope :receives_in_app, -> { where(in_app_notifications: true) }
  scope :remembers_estudios, -> { where(reminder_estudios: true) }
  scope :remembers_appointments, -> { where(reminder_appointments: true) }
  scope :receives_marketing, -> { where(marketing_emails: true) }
end
