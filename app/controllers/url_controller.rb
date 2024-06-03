# frozen_string_literal: true

class UrlController < ApplicationController
  def root
    redirect_to(new_url_path)
  end

  def show
    @short_url = ShortUrl.find(params.require(:short_url_id))
  end

  def new; end

  def create
    input_url = params.require(:url)
    @short_url = UrlShortener.new(input_url).save!

    redirect_to url_path(@short_url.id), notice: "URL shortened successfully"
  rescue UrlValidator::InvalidUrlError, UrlValidator::InvalidUrlFormatError => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  def redirect
    url_slug = params.require(:slug)
    short_url = (ShortUrl.find_by(slug: url_slug) if UrlSlugEncoder.default.slug_size >= url_slug.length)

    return redirect_to new_url_path, notice: "URL no longer available" unless short_url.present?

    redirect_to short_url.target_url.external_url, allow_other_host: true
  end
end
