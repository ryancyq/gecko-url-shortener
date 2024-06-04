# frozen_string_literal: true

class UrlRedirectionEvent < ApplicationRecord
  belongs_to :short_url, optional: true
end
