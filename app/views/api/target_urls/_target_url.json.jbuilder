json.id target_url.id
json.url target_url.external_url
json.title target_url.title
json.created_at target_url.created_at

json.shorten_urls do
  json.array! target_url.short_urls, partial: "/api/short_urls/short_url", as: :short_url
end
