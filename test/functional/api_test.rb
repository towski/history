require File.dirname(__FILE__) + "/../test_helper"
require 'rack/test'

#puts last_request.env['sinatra.error']
Api.set :sessions, false
Api.set :environment, :test
context "Api" do
  include Rack::Test::Methods

  def app
    Api.new
  end

  test "directs to authorization if no user_id" do
    get '/'
    assert last_response.redirect?
  end
  
  test "index without a parameter" do
    mock(CACHE).get("1_friends"){[]}
    get '/', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
  end
end
