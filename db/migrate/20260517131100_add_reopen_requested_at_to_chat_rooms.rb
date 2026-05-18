class AddReopenRequestedAtToChatRooms < ActiveRecord::Migration[8.2]
  def change
    add_column :chat_rooms, :reopen_requested_at, :datetime
  end
end
