$LOAD_PATH << './lib'
gem 'sinatra', "= 1.0"
require 'sinatra'
require 'oauth2'
require 'json'
require 'curb'
require 'history'
require 'yaml'

facebook = YAML.load(File.open("config/facebook.yml").read)
if $env != "testing"
  API_KEY = facebook["api_key"]
  SECRET_KEY = facebook["secret_key"]
end

require 'memcache'
CACHE = MemCache.new 'localhost:11211', :namespace => 'my_namespace'
