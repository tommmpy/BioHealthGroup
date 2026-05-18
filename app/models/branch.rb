class Branch < ApplicationRecord
  audited
  has_many :users, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
  validates :phone, presence: true
  validates :enabled, inclusion: { in: [ true, false ] }

  def self.ransackable_attributes(auth_object = nil)
    [ "address", "created_at", "enabled", "id", "name", "phone", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "users" ]
  end
end
