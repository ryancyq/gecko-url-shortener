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
end
