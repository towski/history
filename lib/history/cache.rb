class Cache
  def self.get(key)
    results = CACHE.get(key)
    if !results
      results = yield
      CACHE.set(key, results)
    else
      results
    end
  end

  def self.set(key, value)
    CACHE.set(key, value)
  end
end
