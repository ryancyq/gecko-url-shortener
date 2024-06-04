# frozen_string_literal: true

require "geocoder"

class UrlRedirection::UpdateGeoLocationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    short_url_id = args.shift
    event = UrlRedirectionEvent.find_by(short_url_id:)

    unless event.present?
      logger.warn { "UrlRedirectionEvent for short url id=#{short_url_id} not found" }
      return
    end

    result, * = Geocoder.search(event.ip_address, ip_address: true)
    unless result.present?
      logger.info { "Geocoder returns empty result for #{event.ip_address}" }
      return
    end

    update_params = {
      country: result.country.presence,
      city: result.city.presence
    }.compact

    logger.info { "Geocoder returns result without geolocation for #{event.ip_address}" } if update_params.blank?

    event.update!(update_params) if update_params.key?(:country)
  end
end
