$LOAD_PATH << './lib'
gem 'sinatra', "= 1.0"
require 'sinatra'
require 'oauth2'
require 'json'
require 'curb'
require 'history'

API_KEY = "7fe35615dfcad9281348a8418a99fa58"
SECRET_KEY = "30935b5f6fd56e5a99727cb812015f6b"

require 'memcache'
CACHE = MemCache.new 'localhost:11211', :namespace => 'my_namespace'
