# frozen_string_literal: true

module Api
  class ShortUrlsController < ApiController
    before_action :load_target_url
    before_action :load_short_url, only: %i[show destroy]

    def index
      render json: @target_url.short_urls
    end

    def show
      render json: @short_url
    end

    def create
      input_url = @target_url.external_url
      short_url = UrlShortener.new(input_url).save!

      render status: :created, json: short_url
    end

    def destroy
      @short_url.destroy!
    end

    private

    def load_target_url
      target_url_id = params.require(:target_url_id)
      @target_url = TargetUrl.find(target_url_id)
    end

    def load_short_url
      short_url_id = params.require(:id)
      @short_url = @target_url.short_urls.where(id: short_url_id).first!
    end
  end
end
