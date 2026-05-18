module Chat
  class Conversation < ApplicationRecord
    self.table_name = "chat_rooms"

    has_many :messages, dependent: :destroy, class_name: "Chat::Message", foreign_key: :chat_room_id
    has_many :chat_room_participants, dependent: :destroy, class_name: "Chat::Participant", foreign_key: :chat_room_id
    has_many :users, through: :chat_room_participants
    belongs_to :assigned_to, class_name: "User", optional: true, foreign_key: :assigned_to_id

    VALID_KINDS = %w[support system group].freeze

    validates :kind, inclusion: { in: VALID_KINDS }

    scope :ordered, -> { order(updated_at: :desc) }

    scope :prioritized, -> {
      order(
        Arel.sql(
          "CASE
            WHEN reopen_requested_at IS NOT NULL THEN 0
            WHEN closed = false AND assigned_to_id IS NOT NULL THEN 1
            WHEN closed = false AND assigned_to_id IS NULL THEN 2
            WHEN closed = true THEN 3
          END"
        ),
        updated_at: :desc
      )
    }

    scope :open, -> { where(closed: false) }
    scope :support, -> { where(kind: "support") }
    scope :system, -> { where(kind: "system") }
    scope :group_chat, -> { where(kind: "group") }
    scope :pending, -> { where(kind: "support", assigned_to_id: nil, closed: false) }
    scope :active, -> { where(kind: "support").where.not(assigned_to_id: nil).where(closed: false) }

    def other_user(current_user)
      users.where.not(id: current_user.id).first
    end

    def last_message
      messages.order(created_at: :desc).first
    end

    def close!
      update!(closed: true)
    end

    def reopen_requested?
      reopen_requested_at.present?
    end

    def request_reopen!
      update!(reopen_requested_at: Time.current)
    end

    def clear_reopen_request!
      update!(reopen_requested_at: nil)
    end

    def pending?
      assigned_to_id.nil? && !closed?
    end

    def assigned?
      assigned_to_id.present?
    end
  end
end
