class AddShortUrlEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :short_url_events do |t|
      t.string :user_agent, null: false
      t.string :ip_address, null: false
      t.string :path, null: false
      t.string :method, null: false
      t.references :short_urls, null: false, foreign_key: true

      t.timestamps
    end
  end
end
