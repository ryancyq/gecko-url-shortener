class ShortUrl < ApplicationRecord
  belongs_to :target_url

  validates :slug, presence: true, length: { maximum: 15 }
end
