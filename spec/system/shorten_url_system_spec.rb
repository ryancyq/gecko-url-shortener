require "rails_helper"

RSpec.describe "Shorten URL", type: :system, vcr: "valid_new_short_url_system" do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "create shorten URL" do
    visit "/url"

    expect(page).to have_text("Shorten a URL:")
    expect(page).to have_button('Shorten URL')

    fill_in "Shorten a URL:", with: "https://www.ruby-lang.org/en/"
    click_button "Shorten URL"

    expect(page).to have_text("Your URL")
    expect(page).to have_link("https://www.ruby-lang.org/en/", href: "https://www.ruby-lang.org/en/")
    expect(page).to have_text("Shortened URL")
    expect(page).to have_text(/#{page.current_host}:\d+\/.+/)
    expect(page).to have_link('Shorten another', href: "/url")

    click_link "Shorten another"

    expect(page).to have_text("Shorten a URL:")
    expect(page).to have_button('Shorten URL')
  end
end