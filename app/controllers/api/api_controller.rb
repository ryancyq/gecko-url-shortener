# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    rescue_from ActionController::ParameterMissing, with: :handle_param_missing
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

    private

    def handle_param_missing(exception)
      render status: :bad_request, json: { error: "Field ##{exception.param} is required" }
    end

    def handle_record_not_found(exception)
      message = if exception.id.present?
                  "Record with id=#{exception.id} not found"
                else
                  "Record not found"
                end
      render status: :not_found, json: { error: message }
    end
  end
end
