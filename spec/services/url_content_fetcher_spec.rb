# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlContentFetcher do
  subject(:fetcher) { described_class.new(uri) }

  context "when uri is empty" do
    let(:uri) { nil }

    it "raise error" do
      expect { fetcher }.to raise_error(ArgumentError, "Empty uri")
    end
  end

  context "when uri is FTP" do
    let(:uri) { URI.parse("ftp://localhost") }

    it "raise error" do
      expect { fetcher.fetch }.to raise_error(ArgumentError, "Invalid uri type: URI::FTP")
    end
  end

  context "when uri is unreachable" do
    let(:uri) { URI.parse("http://www.ruby-lang.orgs/en/") }

    it "raise error" do
      allow_any_instance_of(URI::HTTP).to receive(:open).and_raise(SocketError)
      expect { fetcher.fetch }.to raise_error(described_class::UnreachableUrlError)
    end
  end

  context "when uri is timeout" do
    let(:uri) { URI.parse("http://www.ruby-lang.ors/eng/") }

    it "raise error" do
      allow_any_instance_of(URI::HTTP).to receive(:open).and_raise(Net::ReadTimeout)
      expect { fetcher.fetch }.to raise_error(described_class::UnreachableUrlError)
    end
  end

  context "when uri is valid" do
    context "with https", vcr: "valid_https_url" do
      let(:uri) { URI.parse("https://www.ruby-lang.org/en/") }

      it "does not raise error" do
        expect { fetcher.fetch }.not_to raise_error
      end

      describe "#fetch" do
        it "return truthy" do
          expect(fetcher.fetch).to be_truthy
        end

        it "set title attr" do
          fetcher.fetch
          expect(fetcher.title).to eq "Ruby Programming Language"
        end
      end
    end

    context "with http to https redirection", vcr: "valid_http_url" do
      let(:uri) { URI.parse("http://www.ruby-lang.org/en/") }

      it "does not raise error" do
        expect { fetcher.fetch }.not_to raise_error
      end

      describe "#fetch" do
        it "return truthy" do
          expect(fetcher.fetch).to be_truthy
        end

        it "set title attr" do
          fetcher.fetch
          expect(fetcher.title).to eq "Ruby Programming Language"
        end
      end
    end
  end
end
