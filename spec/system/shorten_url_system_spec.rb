# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Shorten URL" do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "create shorten URL", vcr: "valid_new_short_url_system" do
    visit "/url"

    expect(page).to have_text("Shorten a URL:")
    expect(page).to have_button("Shorten URL")

    fill_in "Shorten a URL:", with: "https://www.ruby-lang.org/en/"
    click_link_or_button "Shorten URL"

    expect(page).to have_text("URL shortened successfully")
    expect(page).to have_text("Your URL")
    expect(page).to have_link("https://www.ruby-lang.org/en/", href: "https://www.ruby-lang.org/en/")
    expect(page).to have_text("Shortened URL")
    expect(page).to have_text("Ruby Programming Language")
    expect(page).to have_text(%r{#{page.current_host}:\d+/.+})
    expect(page).to have_link("Shorten another", href: "/url")

    click_link_or_button "Shorten another"

    expect(page).to have_text("Shorten a URL:")
    expect(page).to have_button("Shorten URL")
  end

  it "create using incomplete URL format" do
    visit "/url"

    expect(page).to have_text("Shorten a URL:")
    expect(page).to have_button("Shorten URL")

    fill_in "Shorten a URL:", with: "https://helolo.adsa.\\\\edu/\\/"
    click_link_or_button "Shorten URL"

    expect(page).to have_text("Malformed URL: https://helolo.adsa.\\\\edu/\\/")
  end
end
