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
    context "with existing slug" do
      let(:target_url) { create(:target_url) }
      let(:short_url) { create(:short_url, target_url:) }

      it "redirect to target_url" do
        get "/#{short_url.slug}"

        expect(response).to redirect_to(target_url.external_url)
      end

      it "creates url redirection event" do
        expect do
          get "/#{short_url.slug}"
        end.to change(UrlRedirectionEvent, :count).by(1)

        expect(response).to redirect_to(target_url.external_url)
        expect(short_url.url_redirection_events.size).to eq 1
        expect(short_url.url_redirection_events.first.path).to eq "/#{short_url.slug}"
      end

      it "creates different url redirection events for different slug" do
        get "/#{short_url.slug}"
        expect(response).to redirect_to(target_url.external_url)
        expect(short_url.url_redirection_events.size).to eq 1
        expect(short_url.url_redirection_events.first.path).to eq "/#{short_url.slug}"

        another_short_url = create(:short_url, target_url:)
        get "/#{another_short_url.slug}"
        expect(response).to redirect_to(target_url.external_url)
        expect(another_short_url.url_redirection_events.size).to eq 1
        expect(another_short_url.url_redirection_events.first.path).to eq "/#{another_short_url.slug}"
      end

      it "creates multiple url redirection events under same slug" do
        expect do
          5.times { get "/#{short_url.slug}" }
          expect(response).to redirect_to(target_url.external_url)
        end.to change(UrlRedirectionEvent, :count).by(5)

        expect(short_url.url_redirection_events.size).to eq 5
        expect(short_url.url_redirection_events.map(&:path)).to all(eq "/#{short_url.slug}")
      end

      it "enqueues update geolocation job" do
        expect { get "/#{short_url.slug}" }.to have_enqueued_job(
          UrlRedirection::UpdateGeoLocationJob
        ).with(kind_of(Integer), short_url.id)
        # unable to get exact event id inline with GET request
      end
    end

    context "with non-existing slug" do
      let(:slug) { "non-existing" }

      it "redirect to url#new" do
        get "/#{slug}"

        expect(response).to redirect_to(new_url_path)
      end

      it "does not create url redirection event" do
        expect { get "/#{slug}" }.not_to change(UrlRedirectionEvent, :count)

        expect(response).to redirect_to(new_url_path)
      end

      it "does not enqueue update geolocation job" do
        expect { get "/#{slug}" }.not_to have_enqueued_job(UrlRedirection::UpdateGeoLocationJob)
      end
    end
  end

  describe "read client remote ip" do
    let(:short_url) { create(:short_url) }

    context "with any environment" do
      it "reads from request#remote_ip" do
        get "/#{short_url.slug}", headers: { "HTTP_X_FORWARDED_FOR" => "8.8.8.8" }

        short_url.url_redirection_events.reload
        event = short_url.url_redirection_events.last
        expect(event.ip_address).to eq "8.8.8.8"
      end
    end

    context "with production environment in fly.io" do
      before do
        allow(Rails).to receive_message_chain(:env, :development?) { false }
        allow(Rails).to receive_message_chain(:env, :production?) { true }
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("FLY_APP_NAME").and_return "my-fly-app"
      end

      it "reads from FLY_CLIENT_IP header" do
        get "/#{short_url.slug}", headers: {
          "HTTP_X_FORWARDED_FOR" => "8.8.8.8",
          "HTTP_FLY_CLIENT_IP" => "0.0.0.0"
        }

        short_url.url_redirection_events.reload
        event = short_url.url_redirection_events.last
        expect(event.ip_address).to eq "0.0.0.0"
      end
    end
  end
end
