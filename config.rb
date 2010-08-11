$LOAD_PATH << './lib'
gem 'sinatra', "= 1.0"
require 'sinatra'
require 'oauth2'
require 'json'
require 'curb'
require 'history'
require 'yaml'
require 'memcached'

if ENV["RACK_ENV"] != "production"
  facebook = YAML.load(File.open("config/facebook.yml").read)
  API_KEY = facebook["api_key"]
  SECRET_KEY = facebook["secret_key"]
elsif ENV["RACK_ENV"] == "production"
  API_KEY = ENV["API_KEY"]
  SECRET_KEY = ENV["SECRET_KEY"]
end

CACHE = Memcached.new

def query(query)
  access_token = User.new(6008237).access_token
  JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
end

def comment_get
  access_token = User.new(6008237).access_token
  Comment.fetch(6008237, 6008379, access_token)
end
