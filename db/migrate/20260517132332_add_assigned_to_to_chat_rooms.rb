class AddAssignedToToChatRooms < ActiveRecord::Migration[8.2]
  def change
    add_column :chat_rooms, :assigned_to_id, :integer
    add_index :chat_rooms, :assigned_to_id
    add_foreign_key :chat_rooms, :users, column: :assigned_to_id
  end
end
