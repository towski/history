require File.dirname(__FILE__) + "/../test_helper"
require 'rack/test'

#puts last_request.env['sinatra.error']
context "Api" do
  include Rack::Test::Methods

  def app
    Api.new
  end

  test "form page" do
    get '/'
    assert last_response.redirect?
  end
end
