
class UrlShortener
  def initialize(external_url)
    @external_url = external_url
  end
  
  def save!
    ActiveRecord::Base.transaction do
      saved_target_url = find_or_create_target_url!(@external_url)
      create_short_url!(saved_target_url)
    end
  end

private

  def find_or_create_target_url!(external_url)
    validator = UrlValidator.new(external_url)
    validator.validate!
    url_title = begin
      fetcher = UrlContentFetcher.new(validator.uri)
      fetcher.fetch
      fetcher.title
    rescue UrlContentFetcher::UnreachableUrlError
      nil
    end

    target_url = TargetUrl.find_or_initialize_by(external_url: validator.uri.to_s)
    target_url.title = url_title
    target_url.save!
    target_url
  end

  def create_short_url!(target_url)
    next_id = (ShortUrl.maximum(:id) || 0) + 1
    slug = UrlSlugEncoder.encode(next_id)
    ShortUrl.create!(target_url: target_url, slug: slug, id: next_id)
  end
end