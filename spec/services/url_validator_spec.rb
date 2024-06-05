# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlValidator do
  subject { described_class.new(url) }

  context "when url is empty" do
    include_examples "invalid url validator", "" do
      let(:error_class) { described_class::UnknownError }
    end
    include_examples "invalid url validator", "     " do
      let(:error_class) { described_class::UnknownError }
    end
  end

  context "when url is malformed" do
    context "with whitespaces" do
      include_examples "invalid url validator", "http://www.goggle.com with white space" do
        let(:error_class) { described_class::UnknownError }
      end
    end

    context "without protocol" do
      include_examples "invalid url validator", "www.goggle.com" do
        let(:error_class) { described_class::MalformedFormatError }
      end
    end

    context "with reserved chars" do
      include_examples "invalid url validator", "https://www.go.co/!@%&&%" do
        let(:error_class) { described_class::UnknownError }
      end
    end
  end

  context "when url is well-formed" do
    include_examples "valid url validator", "https://www.google.com"
    include_examples "valid url validator", "http://www.google.com"
    include_examples "valid url validator", "https://www.google.com/search?q=ruby"
    include_examples "valid url validator", "https://www.google.com/#%7C+ls"
  end

  context "when url contains restricted hostname" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("RESTRICTED_HOSTNAMES", "").and_return(restricted_hostnames)
    end

    context "with multiple hostnames" do
      let(:restricted_hostnames) { "www.google.com,www.github.com," }

      include_examples "invalid url validator", "https://www.github.com" do
        let(:error_class) { described_class::UnsupportedHostnameError }
      end
    end

    context "with fly.io" do
      let(:restricted_hostnames) { "gecko-url-shortener.fly.dev" }
      
      include_examples "invalid url validator", "https://gecko-url-shortener.fly.dev/" do
        let(:error_class) { described_class::UnsupportedHostnameError }
      end
    end
  end
end
