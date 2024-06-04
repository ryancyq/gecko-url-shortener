# frozen_string_literal: true

class AddCountryCityToUrlRedirectionEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :url_redirection_events, :country, :string, null: true
    add_column :url_redirection_events, :city, :string, null: true
  end
end
