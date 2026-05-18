class Testimonial < ApplicationRecord
  audited
  has_one_attached :avatar

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(sort_order: :asc) }

  validates :author_name, :content, presence: true
  validates :avatar, content_type: { in: %w[image/webp image/jpeg image/png], message: "debe ser WebP, JPEG o PNG" },
                     size: { less_than: 2.megabytes, message: "debe ser menor a 2MB" }, if: -> { avatar.attached? }
end
