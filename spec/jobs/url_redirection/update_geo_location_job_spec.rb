# frozen_string_literal: true

require "rails_helper"
require "geocoder"

RSpec.describe UrlRedirection::UpdateGeoLocationJob, type: :job do
  let(:job) { described_class.new }

  context "with non numeric as arg" do
    it "does not invoke geocoder" do
      expect(Geocoder).not_to receive(:search)
      expect { job.perform "abc", "def" }.not_to raise_error
    end
  end

  context "with non-existing id as arg" do
    it "does not invoke geocoder" do
      expect(Geocoder).not_to receive(:search)
      expect { job.perform "9999", "8888" }.not_to raise_error
    end
  end

  context "with existing id as arg" do
    let(:short_url) { build(:short_url) }
    let(:url_redirection_event) do
      create(:url_redirection_event, short_url:, ip_address:, country:, city:)
    end
    let(:country) { "Singapore" }
    let(:city) { "Singapore" }

    context "with public ip address" do
      let(:ip_address) { "66.131.120.255" }

      it "invokes geocoder", vcr: "url_redirection/geolocation_with_public_ip_address" do
        expect(Geocoder).to receive(:search).and_call_original
        expect do
          job.perform(url_redirection_event.id, url_redirection_event.short_url.id)
        end.not_to raise_error
      end

      it "updates country and city of the event", vcr: "url_redirection/geolocation_with_public_ip_address" do
        job.perform(url_redirection_event.id, url_redirection_event.short_url.id)

        url_redirection_event.reload
        expect(url_redirection_event.country).to eq "CA"
        expect(url_redirection_event.city).to eq "Dolbeau-Mistassini"
      end

      it "does not update if data absent", vcr: "url_redirection/geolocation_with_public_ip_address_missing" do
        job.perform(url_redirection_event.id, url_redirection_event.short_url.id)

        url_redirection_event.reload
        expect(url_redirection_event.country).to eq "Singapore"
        expect(url_redirection_event.city).to eq "Singapore"
      end

      it "does not update if country is absent and city is present",
         vcr: "url_redirection/geolocation_with_public_ip_address_partial" do
        job.perform(url_redirection_event.id, url_redirection_event.short_url.id)

        url_redirection_event.reload
        expect(url_redirection_event.country).to eq "Singapore"
        expect(url_redirection_event.city).to eq "Singapore"
      end
    end

    context "with internal ip address" do
      let(:ip_address) { "250.222.51.205" }

      it "invokes geocoder", vcr: "url_redirection/geolocation_with_internal_ip_address" do
        expect(Geocoder).to receive(:search).and_call_original
        expect do
          job.perform(url_redirection_event.id, url_redirection_event.short_url.id)
        end.not_to raise_error
      end

      it "does not update if data absent", vcr: "url_redirection/geolocation_with_internal_ip_address" do
        job.perform(url_redirection_event.id, url_redirection_event.short_url.id)

        url_redirection_event.reload
        expect(url_redirection_event.country).to eq "Singapore"
        expect(url_redirection_event.city).to eq "Singapore"
      end
    end
  end
end
