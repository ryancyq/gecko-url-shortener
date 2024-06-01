require "rails_helper"

RSpec.describe TargetUrl, type: :model do
  subject { build_stubbed(described_class.to_s.underscore) }

  it { is_expected.to be_valid }
end