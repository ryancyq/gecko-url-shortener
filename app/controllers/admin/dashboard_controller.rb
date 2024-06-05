# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  layout "admin"

  def index
    @target_urls = TargetUrl.order(created_at: :desc).all
  end

  def urls
    @target_url = TargetUrl.find(params.require(:target_url_id))
    @short_urls = @target_url.short_urls.order(created_at: :desc)
    @url_visits = short_url_aggregations(@short_urls)
  end

  def url_events
    @short_url_id = params.require(:short_url_id)
    events = UrlRedirectionEvent.where(short_url_id: @short_url_id).order(created_at: :desc)
    @url_events = events.offset(pagination[:offset]).limit(pagination[:page_size])
    @pagination = pagination.merge(total: events.count)
  end

  private

  def short_url_aggregations(short_urls)
    table = UrlRedirectionEvent.arel_table
    count_exp = table[:id].count.as("event_count")
    max_exp = table[:created_at].maximum.as("latest_event")

    result = UrlRedirectionEvent.where(short_url: short_urls)
                                .group(:short_url_id)
                                .pluck(:short_url_id, count_exp.to_sql, max_exp.to_sql)
    result.each_with_object({}) do |(short_url_id, event_count, latest_event), res|
      res[short_url_id] = {
        count: event_count,
        latest: latest_event.presence && Time.parse(latest_event)
      }
    end
  end

  def pagination
    @pagination ||= begin
      page = begin
        params[:page]&.to_i
      rescue StandardError
        1
      end
      page ||= 1 # default page
      page_size = 5 # default page size
      {
        page: page,
        offset: (page - 1) * page_size,
        page_size: page_size
      }
    end
  end
end
