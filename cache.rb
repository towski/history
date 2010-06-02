# Adds support for passing a :cache parameter to action definitions, eg:
# 
#   get '/state_map/?', :cache => 'state_map' do
#     ...
#   end
# 
# :cache can also simply be passed true, in which case the route definition is used as the base 
# key name.  In all cases, any params are also included in the key.
#   
# Author: ben tucker <ben@btucker.net>
# Based on code from: http://railsillustrated.com/blazing-fast-sinatra-with-memcached.html
# Requires: http://github.com/gioext/sinatra-memcache

require 'sinatra/memcache'
require 'digest/md5'

module CacheableRoute
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class << self
        alias_method  :route_without_caching, :route unless method_defined?(:route_without_caching)
        alias_method :route, :route_with_caching
      end
    end 
  end
  module ClassMethods
    def route_with_caching(verb, path, options={}, &block)
      if cache_key = options.delete(:cache)
        cache_key = path if cache_key === true
        def wrap_block(key,block)
          Proc.new do
            cache("#{key}/#{params.to_a.sort.join("/")}") { instance_eval(&block) }
          end
        end
        block = wrap_block(cache_key, block)
      end
      route_without_caching(verb, path, options, &block)
    end
  end 
end

class Sinatra::Base
  include CacheableRoute
end
