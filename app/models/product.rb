class Product < ApplicationRecord
  belongs_to :branch, optional: true

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) if category.present? }

  def self.ransackable_attributes(auth_object = nil)
    %w[name category unit_price stock_quantity active branch_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[branch]
  end
end
