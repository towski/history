class Cache
  def self.get(key)
    results = CACHE.get(key)
    if !results && block_given?
      results = yield 
      CACHE.set(key, results)
    end
    results
  end

  def self.set(key, value)
    CACHE.set(key, value)
  end
end
