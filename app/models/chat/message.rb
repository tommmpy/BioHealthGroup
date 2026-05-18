module Chat
  class Message < ApplicationRecord
    self.table_name = "messages"

    belongs_to :conversation, class_name: "Chat::Conversation", foreign_key: :chat_room_id, touch: true
    belongs_to :user, foreign_key: :user_id

    validates :content, presence: true

    scope :ordered, -> { order(created_at: :asc) }
  end
end
