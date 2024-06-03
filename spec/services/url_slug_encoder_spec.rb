# frozen_string_literal: true

require "rails_helper"

RSpec.describe UrlSlugEncoder do
  describe "#encode" do
    subject(:encoder) { described_class.encode(num) }

    context "when value is nil" do
      let(:num) { nil }

      it { expect { encoder }.to raise_error(ArgumentError, "Encode string can't be blank") }
    end

    context "when value is string" do
      context "with single digit" do
        let(:num) { "1" }

        it { is_expected.to eq "N" }
      end

      context "with double digits" do
        let(:num) { "15" }

        it { is_expected.to eq "3xD" }
      end

      context "with triple digits" do
        let(:num) { "615" }

        it { is_expected.to eq "eCRU" }
      end
    end

    context "when value is negative" do
      let(:num) { -1 }

      it { is_expected.to eq "3h3" }
    end

    context "when value is zero" do
      let(:num) { 0 }

      it { is_expected.to eq "M" }
    end

    context "when value is positive" do
      let(:num) { 1 }

      it { is_expected.to eq "N" }
    end

    context "when value is below MAX_VALUE" do
      let(:num) { "a" * (described_class::MAX_CHARS - 1) }

      it { is_expected.to eq "2ixmpKS37KxeTv" }
      it { expect(encoder.length).to be <= described_class::MAX_LENGTH }
    end

    context "when value is MAX_VALUE" do
      let(:num) { "A" * described_class::MAX_CHARS }

      it { is_expected.to eq "6mnTu2VnVlbWXT3" }
      it { expect(encoder.length).to be <= described_class::MAX_LENGTH }
    end

    context "when value exceeds MAX_VALUE" do
      let(:num) { "n" * (described_class::MAX_CHARS + 1) }

      it {
        expect { encoder }.to raise_error(
          ArgumentError, "Encode string can't be more than 11 chars"
        )
      }
    end
  end

  describe "#decode" do
    subject(:decoder) { described_class.decode(text) }

    context "when text is nil" do
      let(:text) { nil }

      it { expect { decoder }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is empty" do
      let(:text) { "" }

      it { expect { decoder }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is whitespace only" do
      let(:text) { "     " }

      it { expect { decoder }.to raise_error(ArgumentError, "Decode string can't be blank") }
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

      it { expect { decoder }.to raise_error(ArgumentError, "Decode string can't be more than 15 chars") }
    end
  end

  context "when decode output is the same as encode input" do
    let(:input) { "98_765" }

    it "returns the same value" do
      encoded = described_class.encode(input)
      expect(encoded).to be_present
      expect(encoded).not_to eq input

      decoded = described_class.decode(encoded)
      expect(decoded).to be_present
      expect(decoded).not_to eq encoded
      expect(decoded).to eq input
    end
  end
end
