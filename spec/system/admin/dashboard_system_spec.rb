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
    let(:short_url) { build(:short_url, target_url:) }
    let(:another_target_url) { build(:target_url) }
    let(:another_short_url_1) { build(:short_url, target_url: another_target_url) }
    let(:another_short_url_2) { build(:short_url, target_url: another_target_url) }

    before do
      travel_to 1.hour.ago do
        short_url.save
      end
      travel_to 1.day.ago do
        another_short_url_1.save
      end
      travel_to 2.days.ago do
        another_short_url_2.save
      end
    end

    it "shows target urls" do
      visit "/admin"

      expect(page).to have_text("Admin")
      expect(page).to have_css("h2", text: "Target URLs")
      expect(page).to have_text(target_url.title)
      expect(page).to have_link(target_url.external_url, href: target_url.external_url)
      expect(page).to have_text(target_url.created_at.strftime("%b%e, %Y")) # chrome driver default to US timezone
      expect(page).to have_text(another_target_url.title)
      expect(page).to have_link(another_target_url.external_url, href: another_target_url.external_url)
      expect(page).to have_text(another_target_url.created_at.strftime("%b%e, %Y")) # chrome driver default to US timezone
    end

    it "shows short urls" do
      visit "/admin"

      expect(page).to have_text("Admin")
      expect(page).to have_css("h2", text: "Target URLs")

      within "h2 + ul > li:nth-child(2)" do
        expect(page).to have_link("Shorten URLs")
        click_link_or_button "Shorten URLs"

        within "h3 + ul > li:nth-child(1)" do
          expect(page).to have_text(%r{#{page.current_host}:\d+/#{another_short_url_1.slug}})
          expect(page).to have_text("no clicks yet")
        end

        within "h3 + ul > li:nth-child(2)" do
          expect(page).to have_text(%r{#{page.current_host}:\d+/#{another_short_url_2.slug}})
          expect(page).to have_text("no clicks yet")
        end
      end
    end

    it "shows url events" do
      freeze_time do
        create_list(:url_redirection_event, 31, short_url:)
      end

      visit "/admin"

      expect(page).to have_text("Admin")
      expect(page).to have_css("h2", text: "Target URLs")

      within "h2 + ul > li:nth-child(1)" do
        expect(page).to have_link("Shorten URLs")
        click_link_or_button "Shorten URLs"

        within "h3 + ul > li:nth-child(1)" do
          expect(page).to have_text(%r{#{page.current_host}:\d+/#{short_url.slug}})
          expect(page).to have_text("last visited:")
          expect(page).to have_text("31 times")

          expect(page).to have_link("Show Details")
          click_link_or_button "Show Details"

          within "table" do
            within "thead" do
              expect(page).to have_css("th", text: "TIMESTAMP")
              expect(page).to have_css("th", text: "USER AGENT")
              expect(page).to have_css("th", text: "IP ADDRESS")
              expect(page).to have_css("th", text: "COUNTRY")
              expect(page).to have_css("th", text: "CITY")
            end
            within "tbody" do
              expect(page).to have_css("tr", count: 5)
              event = short_url.url_redirection_events.order(created_at: :desc).first
              timestamp = event.created_at.localtime.strftime("%Y/%m/%d %H:%M:%S").strip
              expect(page).to have_css("td > time", count: 5, text: timestamp)
            end
          end

          within "nav" do
            expect(page).to have_text("Showing 1 - 5 of 31")
            within "ul" do
              expect(page).to have_css("li", count: 9)
              expect(page).to have_css("li:first-child span", text: "Previous")
              expect(page).to have_css("li:last-child a", text: "Next")
            end
            click_link_or_button "Next"
            expect(page).to have_text("Showing 6 - 10 of 31")

            click_link_or_button "7"
            expect(page).to have_text("Showing 31 of 31")
          end
        end
      end
    end
  end
end
