require "rails_helper"

RSpec.describe ShortUrl, type: :model do
  subject { build_stubbed(described_class.to_s.underscore) }

  it { is_expected.to be_valid }

  describe "#target_url" do
    it "must exist" do
      subject.target_url = nil
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include(
        "Target url must exist"
      )
    end
  end

  describe "#slug" do
    it "must be present" do
      subject.slug = nil
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include(
        "Slug can't be blank"
      )
    end

    it "can be less than 15 chars" do
      subject.slug = FFaker::Lorem.characters(2)
      expect(subject).to be_valid
    end

    it "must not excceed 15 chars" do
      subject.slug = FFaker::Lorem.characters(20)
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include(
        "Slug is too long (maximum is 15 characters)"
      )
    end
  end
end
