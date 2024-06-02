class UrlController < ApplicationController
  def root
    redirect_to(new_url_path)
  end

  def new
  end

  def show
    @short_url = ShortUrl.find(params.require(:short_url_id))
  end

  def create
    input_url = params.require(:url)
    @short_url = UrlShortener.new(input_url).save!
    
    respond_to do |format|
      format.html { redirect_to url_path(@short_url.id) }
    end
  end

  def redirect
    url_slug = params.require(:slug)[0...UrlSlugEncoder::MAX_LENGTH]
    short_url = ShortUrl.find_by(slug: url_slug)
    
    if short_url.present?
      redirect_to(short_url.target_url.external_url, allow_other_host: true)
    else
      redirect_to(new_url_path)
    end
  end
end
