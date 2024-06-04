class RenameShortUrlEvent < ActiveRecord::Migration[7.1]
  def change
    rename_table :short_url_events, :url_redirection_events
  end
end
