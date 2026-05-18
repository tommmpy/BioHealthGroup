class CreateChatRoomParticipants < ActiveRecord::Migration[8.2]
  def change
    create_table :chat_room_participants do |t|
      t.references :chat_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :chat_room_participants, [ :chat_room_id, :user_id ], unique: true
  end
end
