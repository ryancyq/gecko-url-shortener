# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Redirect URL" do
  let(:external_url) { "https://www.ruby-lang.org/en/" }
  let(:short_url) { create(:short_url, target_url: build(:target_url, external_url:)) }

  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "visit URL with slug" do
    visit "/#{short_url.slug}"

    expect(page.current_host).to eq "https://www.ruby-lang.org"
  end

  it "visit URL with invalid slug" do
    visit "/#{short_url.slug}random"

    expect(page).to have_text("URL no longer available")
    expect(page).to have_text("Enter a URL:")
    expect(page).to have_button("Shorten URL")
  end
end
