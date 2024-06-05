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
end
