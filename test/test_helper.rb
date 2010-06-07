$env = "testing"
require 'rubygems'
require 'ruby-debug'
require File.dirname(__FILE__) + '/../config'
require 'test/unit'
require 'rr'
API_KEY="something"
SECRET_KEY="something"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
end
