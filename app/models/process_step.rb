class ProcessStep < ApplicationRecord
  audited
  has_one_attached :image

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(step_number: :asc) }

  validates :step_number, :title, :description, presence: true
  validates :image, content_type: { in: %w[image/webp image/jpeg image/png], message: "debe ser WebP, JPEG o PNG" },
                    size: { less_than: 5.megabytes, message: "debe ser menor a 5MB" }, if: -> { image.attached? }
end
