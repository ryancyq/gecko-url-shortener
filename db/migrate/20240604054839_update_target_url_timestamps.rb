# frozen_string_literal: true

class UpdateTargetUrlTimestamps < ActiveRecord::Migration[7.1]
  def up
    add_column :target_urls, :updated_at, :datetime, null: true
    execute <<-SQL.squish
      UPDATE target_urls SET updated_at = created_at;
    SQL
    change_column_null :target_urls, :updated_at, false
    change_column_null :target_urls, :created_at, false
  end

  def down
    remove_column :target_urls, :updated_at
    change_column_null :target_urls, :created_at, true
  end
end
