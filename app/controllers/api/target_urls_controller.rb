# frozen_string_literal: true

module Api
  class TargetUrlsController < ApiController
    before_action :load_target_url, only: %i[show destroy]

    rescue_from UrlValidator::InvalidUrlError, UrlValidator::InvalidUrlFormatError, with: :handle_url_errors

    def index
      target_urls = TargetUrl.all
      render json: target_urls
    end

    def show
      render json: @target_url
    end

    def create
      input_url = params.require(:url)
      short_url = UrlShortener.new(input_url).save!

      render status: :created, json: short_url.target_url
    end

    def destroy
      @target_url.destroy!
    end

    private

    def load_target_url
      target_url_id = params.require(:id)
      @target_url = TargetUrl.find(target_url_id)
    end

    def handle_url_errors(exception)
      render status: :unprocessable_entity, json: { error: exception.message }
    end
  end
end
