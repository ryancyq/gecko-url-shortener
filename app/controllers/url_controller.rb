class UrlController < ApplicationController
  def root
    redirect_to(new_url_path)
  end

  def new
  end

  def create
  end

  def redirect
    redirect_to("https://www.google.com", allow_other_host: true)
  end
end
