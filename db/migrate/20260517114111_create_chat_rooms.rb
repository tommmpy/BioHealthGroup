class CreateChatRooms < ActiveRecord::Migration[8.2]
  def change
    create_table :chat_rooms do |t|
      t.string :title
      t.timestamps
    end
  end
end
