# frozen_string_literal: true

class TargetUrl < ApplicationRecord
  has_many :short_urls, dependent: :destroy

  validates :external_url, presence: true
end
