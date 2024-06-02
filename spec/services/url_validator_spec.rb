# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlValidator do
  subject { described_class.new(url) }

  context "when url is empty" do
    include_examples "invalid url validator", "", described_class::InvalidUrlError
    include_examples "invalid url validator", "     ", described_class::InvalidUrlError
  end

  context "when url is malformed" do
    context "with whitespaces" do
      include_examples "invalid url validator", "http://www.goggle.com with white space",
                       described_class::InvalidUrlError
    end

    context "without protocol" do
      include_examples "invalid url validator", "www.goggle.com", described_class::InvalidUrlFormatError
    end

    context "with reserved chars" do
      include_examples "invalid url validator", "https://www.go.co/!@%&&%", described_class::InvalidUrlError
    end
  end

  context "when url is well-formed" do
    include_examples "valid url validator", "https://www.google.com"
    include_examples "valid url validator", "http://www.google.com"
    include_examples "valid url validator", "https://www.google.com/search?q=ruby"
    include_examples "valid url validator", "https://www.google.com/#%7C+ls"
  end
end
