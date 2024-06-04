# frozen_string_literal: true

class UrlRedirection::UpdateGeoLocationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    short_url_id = args.shift
    event = UrlRedirectionEvent.find_by(short_url_id:)

    unless event.present?
      logger.warn { "UrlRedirectionEvent for short url id=#{short_url_id} not found" }
      return
    end
  end
end
