class Session < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(terminated_at: nil) }
  scope :recently_active, -> {
    where(terminated_at: nil).or(where(terminated_at: 10.minutes.ago..))
  }
end
