class RemoveShortUrlNotNullConstraintForEvent < ActiveRecord::Migration[7.1]
  def change
    change_column_null :short_url_events, :short_urls_id, true
  end
end
