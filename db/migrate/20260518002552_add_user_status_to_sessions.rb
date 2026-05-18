class AddUserStatusToSessions < ActiveRecord::Migration[8.2]
  def change
    add_column :sessions, :user_status, :integer, default: 0, null: false
  end
end
