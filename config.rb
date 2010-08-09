$LOAD_PATH << './lib'
gem 'sinatra', "= 1.0"
require 'sinatra'
require 'oauth2'
require 'json'
require 'curb'
require 'history'
require 'yaml'
require 'memcache'

if $env == "development"
  facebook = YAML.load(File.open("config/facebook.yml").read)
  API_KEY = facebook["api_key"]
  SECRET_KEY = facebook["secret_key"]
  CACHE = MemCache.new 'localhost:11211', :namespace => 'my_namespace'
elsif ENV["RACK_ENV"] == "production"
  API_KEY = ENV["API_KEY"]
  SECRET_KEY = ENV["SECRET_KEY"]
  CACHE = Memcached.new
else
  CACHE = MemCache.new 'localhost:11211', :namespace => 'test'
end

def query(query)
  access_token = User.new(6008237).access_token
  JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
end
