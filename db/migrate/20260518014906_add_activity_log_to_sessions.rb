class AddActivityLogToSessions < ActiveRecord::Migration[8.2]
  def change
    add_column :sessions, :activity_log, :jsonb, default: []
  end
end
