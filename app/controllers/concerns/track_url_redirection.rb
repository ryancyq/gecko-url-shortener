# frozen_string_literal: true

module TrackUrlRedirection
  extend ActiveSupport::Concern

  included do
    before_action :set_url_redirection
    after_action :save_url_redirection
  end

  def track_url_redirection(short_url)
    Current.url_redirection_event.short_url = short_url if short_url.is_a?(ShortUrl)
    Current.url_redirection_event.short_url_id = short_url if short_url.is_a?(Integer)
  end

  private

  def set_url_redirection
    Current.url_redirection_event ||= build_url_redirection_event
  end

  def save_url_redirection
    Current.url_redirection_event.save! if url_redirected?
  end

  def url_redirected?
    Current.url_redirection_event.short_url.present? || Current.url_redirection_event.short_url_id.present?
  end

  def build_url_redirection_event
    UrlRedirectionEvent.new(
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      path: request.path,
      method: request.method
    )
  end
end
