# frozen_string_literal: true

require "uri"

class UrlValidator
  class InvalidUrlError < StandardError; end
  class InvalidUrlFormatError < StandardError; end

  attr_reader :uri

  def initialize(url_string)
    @url = url_string.presence
  end

  def validate!
    result = URI.parse(@url)
    raise InvalidUrlFormatError, "Unsupport url format: #{@url}" unless result.is_a?(URI::HTTP)

    @uri = result
  rescue URI::InvalidURIError
    raise InvalidUrlError, "Malformed url: #{@url}"
  end

  def valid?
    validate! unless defined? @uri
    @uri.present?
  rescue InvalidUrlError, InvalidUrlFormatError
    false
  end
end
