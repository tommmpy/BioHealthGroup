module Chat
  class Participant < ApplicationRecord
    self.table_name = "chat_room_participants"

    belongs_to :conversation, class_name: "Chat::Conversation", foreign_key: :chat_room_id
    belongs_to :user, foreign_key: :user_id

    validates :user_id, uniqueness: { scope: :chat_room_id }
  end
end
