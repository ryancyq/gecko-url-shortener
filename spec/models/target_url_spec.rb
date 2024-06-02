# frozen_string_literal: true

require "rails_helper"

RSpec.describe TargetUrl do
  subject(:model) { build_stubbed(described_class.to_s.underscore) }

  it { is_expected.to be_valid }

  describe "#external_url" do
    it "must be present" do
      model.external_url = nil
      expect(model).not_to be_valid
      expect(model.errors.full_messages).to include(
        "External url can't be blank"
      )
    end
  end
end
