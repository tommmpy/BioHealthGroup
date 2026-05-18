class AddKindToChatRooms < ActiveRecord::Migration[8.2]
  def change
    add_column :chat_rooms, :kind, :string, default: "support", null: false
    add_index :chat_rooms, :kind
  end
end
