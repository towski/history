class Cache
  def self.get(key)
    begin
      results = CACHE.get(key)
    rescue Memcached::NotFound
      if block_given?
        results = yield 
        CACHE.set(key, results)
      end
    end
    results
  end

  def self.set(key, value)
    CACHE.set(key, value)
  end
end
