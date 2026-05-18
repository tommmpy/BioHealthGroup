class CreateNotificationPreferences < ActiveRecord::Migration[8.2]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :email_notifications, default: true
      t.boolean :in_app_notifications, default: true
      t.boolean :reminder_estudios, default: true
      t.boolean :reminder_appointments, default: true
      t.boolean :marketing_emails, default: false
      t.timestamps
    end
  end
end
