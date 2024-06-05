# frozen_string_literal: true

require "geocoder"

module UrlRedirection
  class UpdateGeoLocationJob < ApplicationJob
    queue_as :default

    def perform(*args)
      event_id, short_url_id = args
      event = UrlRedirectionEvent.find_by(id: event_id, short_url_id: short_url_id)

      if event.blank?
        logger.warn { "UrlRedirectionEvent id=#{event_id} short_url_id=#{short_url_id} not found" }
        return
      end

      result, * = Geocoder.search(event.ip_address, ip_address: true)
      if result.blank?
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
end
