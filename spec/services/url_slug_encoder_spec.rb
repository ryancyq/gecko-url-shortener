require "rails_helper"

RSpec.describe UrlSlugEncoder do
  describe "#encode" do
    subject { described_class.encode(num) }

    context "when value is nil" do
      let(:num) { nil }
      it { expect { subject }.to raise_error(ArgumentError, "Encode value can't be blank") }
    end

    context "when value is string" do
      let(:num) { "1" }
      it { expect { subject }.to raise_error(ArgumentError, "Encode value must be Integer") }
    end

    context "when value is negative" do
      let(:num) { -1 }
      it { is_expected.to be_nil }
    end

    context "when value is zero" do
      let(:num) { -0 }
      it { is_expected.to eq "0" }
    end

    context "when value is positive" do
      let(:num) { 1 }
      it { is_expected.to eq "1" }
    end

    context "when value is below MAX_VALUE" do
      let(:num) { described_class::MAX_VALUE - 1 }
      it { is_expected.to eq "ZZZZZZZZZZZZZZY" }
      it { expect(subject.length).to be <= described_class::MAX_LENGTH }
    end

    context "when value is MAX_VALUE" do
      let(:num) { described_class::MAX_VALUE }
      it { is_expected.to eq "ZZZZZZZZZZZZZZZ" }
      it { expect(subject.length).to be <= described_class::MAX_LENGTH }
    end

    context "when value exceeds MAX_VALUE" do
      let(:num) { described_class::MAX_VALUE + 1 }
      it { expect { subject }.to raise_error(ArgumentError, "Encode value can't be greater than 768909704948766668552634367") }
    end
  end

  describe "#decode" do
    subject { described_class.decode(text) }

    context "when text is nil" do
      let(:text) { nil }
      it { expect { subject }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is empty" do
      let(:text) { "" }
      it { expect { subject }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is whitespace only" do
      let(:text) { "     " }
      it { expect { subject }.to raise_error(ArgumentError, "Decode string can't be blank") }
    end

    context "when text is 1 char" do
      let(:text) { "m" }
      it { is_expected.to eq 22 }
    end

    context "when text is more than 1 char and less than 15 chars" do
      let(:text) { "mBa2vcC9esdp51s" }
      it { is_expected.to eq 280272376445206540999443446 }
    end

    context "when text is more than 15 chars" do
      let(:text) { "mBa2vcC9esdp51s1fbvLerv0P2Nc9D" }
      it { expect { subject }.to raise_error(ArgumentError, "Decode string can't be more than 15 chars") }
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
      expect(decoded).to eq input
    end
  end
end