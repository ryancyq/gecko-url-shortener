# frozen_string_literal: true

class ShortUrl < ApplicationRecord
  belongs_to :target_url
  has_many :url_redirection_events, dependent: :nullify

  validates :slug, presence: true, length: { maximum: 15 }
end
