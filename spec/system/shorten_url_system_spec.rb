require "rails_helper"

RSpec.describe "Shorten URL", type: :system do
  it "create shorten URL" do
    visit "/url"

    fill_in "Shorten a URL:", with: "https://google.com"
    click_button "Shorten URL"

    expect(page).to have_text("URL has been shortened")
  end
end