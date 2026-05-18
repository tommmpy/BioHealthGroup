class AddClosedToChatRooms < ActiveRecord::Migration[8.2]
  def change
    add_column :chat_rooms, :closed, :boolean, default: false, null: false
  end
end
