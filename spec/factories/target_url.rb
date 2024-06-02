FactoryBot.define do
  factory :target_url do
    title { FFaker::Lorem.phrase }
    external_url { FFaker::Internet.uri("https") }
  end
end
