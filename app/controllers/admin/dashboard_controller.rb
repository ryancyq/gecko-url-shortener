# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  def index
    @target_urls = TargetUrl.order(created_at: :desc).all
  end
end
