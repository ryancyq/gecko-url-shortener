FactoryBot.define do
  factory :target_url do
    title { FFaker::Lorem.words(3) }
    external_url { FFaker::Internet.uri('https') }
  end
end