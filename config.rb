$LOAD_PATH << './lib'
gem 'sinatra', "= 1.0"
require 'sinatra'
require 'oauth2'
require 'json'
require 'curb'
require 'history'
require 'yaml'
require 'memcache'

facebook = YAML.load(File.open("config/facebook.yml").read)
if $env != "testing"
  API_KEY = facebook["api_key"]
  SECRET_KEY = facebook["secret_key"]
  CACHE = MemCache.new 'localhost:11211', :namespace => 'my_namespace'
else
  CACHE = MemCache.new 'localhost:11211', :namespace => 'test'
end

def query(query)
  access_token = User.new(6008237).access_token
  JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
end
