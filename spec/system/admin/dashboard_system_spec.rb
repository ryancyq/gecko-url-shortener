# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Dashbaord" do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  context "with no shorten URLs" do
    it "shows empty state" do
      visit "/admin"

      expect(page).to have_text("Admin")
      expect(page).to have_text("There are no URLs being shortened.")
    end
  end

  context "with shorten URLs" do
    let(:target_url) { build(:target_url) }
    let(:another_target_url) { build(:target_url) }

    before do
      create(:short_url, target_url:)
      create(:short_url, target_url: another_target_url)
    end

    it "shows target urls" do
      visit "/admin"

      expect(page).to have_text("Admin")
      expect(page).to have_text("Target URLs")
      expect(page).to have_text(target_url.title)
      expect(page).to have_link(target_url.external_url, href: target_url.external_url)
      expect(page).to have_text(another_target_url.title)
      expect(page).to have_link(another_target_url.external_url, href: another_target_url.external_url)
    end
  end
end
