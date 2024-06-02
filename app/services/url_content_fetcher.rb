require 'uri'
require 'open-uri'

class UrlContentFetcher
  class UnreachableUrlError < StandardError; end

  ERRORS = [
    SocketError,
    OpenURI::HTTPError,
    Net::OpenTimeout,
    Net::ReadTimeout
  ].freeze

  attr_reader :title

  def initialize(uri)
    @uri = uri.presence || raise(ArgumentError.new("Empty uri"))

    unless @uri.is_a?(URI::HTTP)
      raise ArgumentError.new("Invalid uri type: #{@uri.class}")
    end
  end
  
  def fetch
    @title = extract_title
    @title.present?
  end

private

  def extract_title
    # using open-uri overrides here to make use of url redirection
    content = @uri.open("User-Agent" => "Ruby/#{RUBY_VERSION}").read
    match_data = content.match /<title>(?<text>.*?)<\/title>/
    match_data[:text] if match_data
  rescue *ERRORS
    raise UnreachableUrlError
  end
end