# frozen_string_literal: true

require "uri"

class UrlValidator
  class UrlError < StandardError; end
  class UnknownError < UrlError; end
  class MalformedFormatError < UrlError; end
  class UnsupportedHostnameError < UrlError; end

  attr_reader :uri

  def initialize(url_string)
    @url = url_string.presence
    @restricted_hostnames = ENV.fetch("RESTRICTED_HOSTNAMES", "").split(",").map(&:strip)
  end

  def validate!
    parsed_uri = URI.parse(@url)
    raise MalformedFormatError, "Malformed URL: #{parsed_uri}" unless parsed_uri.is_a?(URI::HTTP)

    if @restricted_hostnames.include?(parsed_uri.hostname)
      raise UnsupportedHostnameError, "Unsupported hostname: #{parsed_uri.hostname}"
    end

    @uri = parsed_uri
  rescue URI::InvalidURIError
    raise UnknownError, "Unknown URL: #{@url}"
  end

  def valid?
    validate! unless defined? @uri
    @uri.present?
  rescue UrlError
    false
  end
end
