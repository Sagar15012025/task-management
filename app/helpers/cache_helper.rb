module CacheHelper
  CACHE_EXPIRY = CACHE_EXPIRY_DURATION

  def fetch_from_cache(key)
    Rails.cache.fetch(key, expires_in: CACHE_EXPIRY) { yield }
  end

  def delete_cache(key)
    Rails.cache.delete(key)
  end
end
