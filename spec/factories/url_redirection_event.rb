# frozen_string_literal: true

FactoryBot.define do
  factory :url_redirection_event do
    short_url { nil }
    user_agent { "" }
    ip_address { FFaker::Internet.ip_v4_address }
    path { "/#{short_url&.slug || FFaker::Lorem.characters(15)}" }
    add_attribute(:method) { "GET" }
  end
end
