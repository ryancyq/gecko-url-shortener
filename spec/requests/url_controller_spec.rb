# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlController do
  describe "GET root" do
    it "redirect to new_url_path" do
      get "/"

      expect(response).to redirect_to("/url")
    end
  end

  describe "GET slug" do
    let(:target_url) { create(:target_url) }
    let(:short_url) { create(:short_url, target_url:) }

    it "redirect to target_url" do
      get "/#{short_url.slug}"

      expect(response).to redirect_to(target_url.external_url)
    end
  end
end
