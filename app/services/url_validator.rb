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
  end

  def validate!
    result = URI.parse(@url)
    raise MalformedFormatError, "Malformed URL: #{@url}" unless result.is_a?(URI::HTTP)

    @uri = result
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
