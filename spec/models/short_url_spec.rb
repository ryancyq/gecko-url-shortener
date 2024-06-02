# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShortUrl do
  subject(:model) { build_stubbed(described_class.to_s.underscore) }

  it { is_expected.to be_valid }

  describe "#target_url" do
    it "must exist" do
      model.target_url = nil
      expect(model).not_to be_valid
      expect(model.errors.full_messages).to include(
        "Target url must exist"
      )
    end
  end

  describe "#slug" do
    it "must be present" do
      model.slug = nil
      expect(model).not_to be_valid
      expect(model.errors.full_messages).to include(
        "Slug can't be blank"
      )
    end

    it "can be less than 15 chars" do
      model.slug = FFaker::Lorem.characters(2)
      expect(model).to be_valid
    end

    it "must not excceed 15 chars" do
      model.slug = FFaker::Lorem.characters(20)
      expect(model).not_to be_valid
      expect(model.errors.full_messages).to include(
        "Slug is too long (maximum is 15 characters)"
      )
    end
  end
end
