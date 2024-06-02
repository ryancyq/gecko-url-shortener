# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlShortener do
  subject(:shortener) { described_class.new(url) }

  context "when url is empty" do
    let(:url) { "" }

    it "raise error" do
      expect { shortener.save! }.to raise_error(UrlValidator::InvalidUrlError).and change(TargetUrl, :count).by(0)
    end
  end

  context "when url is malformed" do
    context "with whitespaces" do
      let(:url) { "http://www.goggle.com with white space" }

      it "raise error" do
        expect { shortener.save! }.to raise_error(UrlValidator::InvalidUrlError).and change(TargetUrl, :count).by(0)
      end
    end

    context "without protocol" do
      let(:url) { "www.goggle.com" }

      it "raise error" do
        expect { shortener.save! }.to raise_error(UrlValidator::InvalidUrlFormatError).and change(TargetUrl, :count).by(0)
      end
    end

    context "with reserved chars" do
      let(:url) { "https://www.go.co/!@%&&%" }

      it "raise error" do
        expect { shortener.save! }.to raise_error(UrlValidator::InvalidUrlError).and change(TargetUrl, :count).by(0)
      end
    end
  end

  context "when url is well-formed" do
    context "with new url", vcr: "valid_shorten_new_url" do
      let(:url) { "https://www.google.com" }

      it "returns ShortUrl object" do
        expect(shortener.save!).to be_a(ShortUrl)
      end

      it "creates target and short url" do
        expect { shortener.save! }.to change(TargetUrl, :count).by(1).and change(ShortUrl, :count).by(1)
        target_url = TargetUrl.find_by(external_url: url)
        expect(target_url).to be_present
        expect(target_url.title).to eq "Google"
        expect(target_url.short_urls).not_to be_empty
        expect(target_url.short_urls.first).to be_present
        expect(target_url.short_urls.first.slug).to be_present
      end
    end

    context "with existing url", vcr: "valid_shorten_existing_url" do
      let(:url) { "https://www.google.com" }
      let(:url_title) { "random title" }
      let(:existing_short_url) do
        build(:short_url, target_url: build(:target_url, external_url: url, title: url_title))
      end

      before do
        existing_short_url.save!
      end

      it "update target url title" do
        expect(existing_short_url.target_url.title).to eq url_title
        expect { shortener.save! }.to change(TargetUrl, :count).by(0).and change(ShortUrl, :count).by(1)

        target_url = existing_short_url.target_url.reload
        expect(target_url.title).to eq "Google"
      end

      it "creates short url only" do
        expect { shortener.save! }.to change(TargetUrl, :count).by(0).and change(ShortUrl, :count).by(1)
        target_url = TargetUrl.find_by(external_url: url)
        expect(target_url.title).to eq "Google"
        expect(target_url).to be_present
        expect(target_url.short_urls.size).to eq 2

        first, second = target_url.short_urls
        expect(first).to be_present
        expect(first.slug).to be_present
        expect(second).to be_present
        expect(second.slug).to be_present
        expect(first.slug).not_to eq second.slug
      end
    end
  end
end
