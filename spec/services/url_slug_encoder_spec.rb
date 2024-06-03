# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlSlugEncoder do
  describe "#encode" do
    subject(:output) { encoder.encode(num) }

    let(:encoder) { described_class.default }

    context "when value is nil" do
      let(:num) { nil }

      it { expect { output }.to raise_error(ArgumentError, "Encode string can't be blank") }
    end

    context "when value is string" do
      context "with single digit" do
        let(:num) { "1" }

        it { is_expected.to eq "4NhuQh0in8WwpPi" }
      end

      context "with double digits" do
        let(:num) { "15" }

        it { is_expected.to eq "5btOy7XkIirhkNq" }
      end

      context "with triple digits" do
        let(:num) { "615" }

        it { is_expected.to eq "5btQG032cp2h26Y" }
      end
    end

    context "when value is negative" do
      let(:num) { -1 }

      it { is_expected.to eq "4Nd6ABewdwz8Zt6" }
    end

    context "when value is zero" do
      let(:num) { 0 }

      it { is_expected.to eq "4HeMBrUGsZqWNWM" }
    end

    context "when value is positive" do
      let(:num) { 999 }

      it { is_expected.to eq "5zQqHHb4jo2K7Uk" }
    end

    context "when value is below max_chars" do
      let(:num) { "a" * (encoder.max_chars - 1) }

      it { is_expected.to eq "9uxKylxaU09fvaM" }
      it { expect(output.length).to be <= encoder.slug_size }
    end

    context "when value is max_chars" do
      let(:num) { "A" * encoder.max_chars }

      it { is_expected.to eq "6mnTu2VnVlbWXT3" }
      it { expect(output.length).to be <= encoder.slug_size }
    end

    context "when value exceeds max_chars" do
      let(:num) { "n" * (encoder.max_chars + 1) }

      it {
        expect { output }.to raise_error(
          ArgumentError, "Encode string can't be more than 11 chars"
        )
      }
    end
  end

  describe "#decode" do
    subject(:output) { decoder.decode(text) }

    let(:decoder) { described_class.default }

    context "when text is nil" do
      let(:text) { nil }

      it { expect { output }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is empty" do
      let(:text) { "" }

      it { expect { output }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is whitespace only" do
      let(:text) { "     " }

      it { expect { output }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is 1 char" do
      let(:text) { "Z" }

      it { is_expected.to eq "=" }
    end

    context "when text is more than 1 char and less than 16 chars" do
      let(:text) { "5zQqItgWbaX7PyV" }

      it { is_expected.to eq "99999999999" }
    end

    context "when text is more than 15 chars" do
      let(:text) { "mBa2vcC9esdp51s1fbvLerv0P2Nc9D" }

      it { expect { output }.to raise_error(ArgumentError, "Decode string can't be more than 15 chars") }
    end
  end

  context "when decode output is the same as encode input" do
    let(:input) { 98_765 }

    it "returns the same value" do
      encoded = described_class.encode(input)
      expect(encoded).to be_present
      expect(encoded).not_to eq input

      decoded = described_class.decode(encoded)
      expect(decoded).to be_present
      expect(decoded).not_to eq encoded
      expect(decoded.to_i).to eq input
    end
  end
end
