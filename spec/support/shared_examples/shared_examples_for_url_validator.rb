# frozen_string_literal: true

RSpec.shared_examples "valid url validator" do |url|
  subject { described_class.new(url) }

  context "with #{url}" do
    describe "#valid?" do
      it "set uri attr" do
        subject.validate!
        expect(subject.uri).not_to be_nil
        expect(subject.uri).to be_a(URI::HTTP)
      end

      it { is_expected.to be_valid }
    end

    describe "#validate!" do
      it "set uri attr" do
        subject.validate!
        expect(subject.uri).not_to be_nil
        expect(subject.uri).to be_a(URI::HTTP)
      end

      it "does not raise error" do
        expect { subject.validate! }.not_to raise_error
      end
    end
  end
end

RSpec.shared_examples "invalid url validator" do |url|
  subject { described_class.new(url) }

  context "with #{url}" do
    describe "#valid?" do
      it "does not set uri attr" do
        expect { subject.validate! }.to raise_error(error_class)
        expect(subject.uri).to be_nil
      end

      it { is_expected.not_to be_valid }
    end

    describe "#validate!" do
      it "does not set uri attr" do
        expect { subject.validate! }.to raise_error(error_class)
        expect(subject.uri).to be_nil
      end

      it "raise error" do
        expect { subject.validate! }.to raise_error(error_class)
      end
    end
  end
end
