# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::TargetUrlsController do
  describe "GET index" do
    context "with no records" do
      it "returns sucessful response" do
        get "/api/target_urls", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_empty
      end
    end

    context "with existing records" do
      before { create_list(:target_url, 3) }

      it "returns sucessful response" do
        get "/api/target_urls", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_a(Array)
        expect(response.parsed_body.size).to eq 3
        expect(response.parsed_body).to include(
          hash_including(
            id: kind_of(Integer),
            external_url: be_present,
            title: be_present
          )
        )
      end
    end
  end

  describe "GET show" do
    context "without id" do
      it "returns bad_request response" do
        get "/api/target_urls/%20", as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with no records" do
      it "returns not_found response" do
        get "/api/target_urls/1", as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with existing records" do
      let(:target_url) { create(:target_url) }

      it "returns sucessful response" do
        get "/api/target_urls/#{target_url.id}", as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to be_a(Hash)
        expect(response.parsed_body).to include(
          id: kind_of(Integer),
          external_url: be_present,
          title: be_present
        )
      end
    end
  end

  describe "POST create" do
    context "without url" do
      let(:url) { "" }

      it "returns bad_request response" do
        post "/api/target_urls", params: { url: url }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with invalid url" do
      let(:url) { "ruby-lang.org/en/" }

      it "returns unprocessable_entity response" do
        post "/api/target_urls", params: { url: url }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with valid url", vcr: "requests/valid_target_url_create" do
      let(:url) { "https://www.ruby-lang.org/en/" }

      it "returns sucessful response" do
        post "/api/target_urls", params: { url: url }, as: :json

        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to be_a(Hash)
        expect(response.parsed_body).to include(
          id: kind_of(Integer),
          external_url: eq(url),
          title: be_present
        )
      end
    end
  end

  describe "DELETE destroy" do
    context "without id" do
      it "returns bad_request response" do
        delete "/api/target_urls/%20", as: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with no records" do
      it "returns not_found response" do
        delete "/api/target_urls/1", as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to include(error: be_present)
      end
    end

    context "with existing records" do
      let(:target_url) { create(:target_url) }

      it "returns empty response" do
        delete "/api/target_urls/#{target_url.id}", as: :json

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end
  end
end
