# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ShortUrlsController do
  let(:target_url) { create(:target_url) }
  let(:target_url_path) { "/target_urls/#{target_url.id}" }

  describe "GET index" do
    context "with no records" do
      it "returns sucessful response" do
        get "/api/#{target_url_path}/short_urls", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context "with existing records" do
      before { create_list(:short_url, 3, target_url:) }

      it "returns sucessful response" do
        get "/api/#{target_url_path}/short_urls", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_a(Array)
        expect(response.parsed_body.size).to eq 3
        expect(response.parsed_body).to include(
          hash_including(
            id: kind_of(Integer),
            url: be_present
          )
        )
      end
    end
  end

  describe "GET show" do
    context "without id" do
      it "returns bad_request response" do
        get "/api/#{target_url_path}/short_urls/%20", as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with no records" do
      it "returns not_found response" do
        get "/api/#{target_url_path}/short_urls/1", as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with existing records" do
      let(:short_url) { create(:short_url, target_url:) }

      it "returns sucessful response" do
        get "/api/#{target_url_path}/short_urls/#{short_url.id}", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_a(Hash)
        expect(response.parsed_body).to include(
          id: kind_of(Integer),
          url: be_present
        )
      end
    end
  end

  describe "POST create" do
    context "with existing target_url url", vcr: "requests/valid_target_url_create" do
      let(:target_url) { create(:target_url, external_url: "https://www.ruby-lang.org/en/") }

      it "returns sucessful response" do
        post "/api/#{target_url_path}/short_urls", as: :json

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to be_a(Hash)
        expect(response.parsed_body).to include(
          id: kind_of(Integer),
          url: be_present
        )
      end
    end
  end

  describe "DELETE destroy" do
    context "without id" do
      it "returns bad_request response" do
        delete "/api/#{target_url_path}/short_urls/%20", as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with no records" do
      it "returns not_found response" do
        delete "/api/#{target_url_path}/short_urls/1", as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with existing records" do
      let(:short_url) { create(:short_url, target_url:) }

      it "returns empty response" do
        delete "/api/#{target_url_path}/short_urls/#{short_url.id}", as: :json

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end
  end
end
