# frozen_string_literal: true

class UpdateShortUrlIdInEvent < ActiveRecord::Migration[7.1]
  def change
    remove_index :short_url_events, :short_urls_id, name: "index_short_url_events_on_short_urls_id"
    remove_foreign_key :short_url_events, :short_urls, column: :short_urls_id

    rename_column :short_url_events, :short_urls_id, :short_url_id

    add_foreign_key :short_url_events, :short_urls, column: :short_url_id
    add_index :short_url_events, :short_url_id
  end
end
