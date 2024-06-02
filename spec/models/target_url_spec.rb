# frozen_string_literal: true

require "rails_helper"

RSpec.describe TargetUrl, type: :model do
  subject { build_stubbed(described_class.to_s.underscore) }

  it { is_expected.to be_valid }

  describe "#external_url" do
    it "must be present" do
      subject.external_url = nil
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages).to include(
        "External url can't be blank"
      )
    end
  end
end
