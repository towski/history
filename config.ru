require 'rubygems'
require 'config'
Api.set :public, File.expand_path(File.dirname(__FILE__)) + '/public'
run Api
