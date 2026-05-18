class AddUserNameToSessions < ActiveRecord::Migration[8.2]
  def change
    add_column :sessions, :user_name, :string
  end
end
