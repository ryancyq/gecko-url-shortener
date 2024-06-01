class CreateUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :target_urls do |t|
      t.string :external_url, null: false
      t.string :title
      t.timestamp :created_at

      t.index(:external_url, unique: true)
    end

    create_table :short_urls do |t|
      t.string :slug, null: false
      t.bigint :target_url_id
      t.timestamp :created_at

      t.index(:slug, unique: true)
      t.foreign_key(:target_urls, column: :target_url_id)
    end
  end
end
