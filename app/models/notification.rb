class Notification < ApplicationRecord
  audited
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  scope :prioritized, -> {
    order(
      Arel.sql(
        "CASE kind
          WHEN 'reopen_request' THEN 0
          WHEN 'ticket_accepted' THEN 1
          WHEN 'new_ticket' THEN 1
          WHEN 'new_message' THEN 2
          WHEN 'reopened' THEN 3
          ELSE 4
        END"
      ),
      created_at: :desc
    )
  }

  def mark_as_read!
    update!(read: true)
  end
end
