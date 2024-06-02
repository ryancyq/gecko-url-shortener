# frozen_string_literal: true

FactoryBot.define do
  factory :short_url do
    target_url

    slug { FFaker::Lorem.characters(15) }
  end
end
