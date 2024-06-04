module TrackUrlRedirection
  extend ActiveSupport::Concern

  def track_url_redirection
    UrlRedirectionEvent.create!(
      short_url: @short_url,
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      path: request.path,
      method: request.method
    )
  end
end
