# frozen_string_literal: true

class RemoveUserAgentNotNullConstraint < ActiveRecord::Migration[7.1]
  def change
    change_column_null :short_url_events, :user_agent, true
  end
end
