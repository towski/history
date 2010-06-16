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
  
  test "request facebook auth redirect" do
    get '/auth/facebook'
    assert last_response.redirect?
  end
  
  test "get friends without a parameter" do
    mock(CACHE).get("1_friends"){[]}
    mock(CACHE).get("1_something").twice { "something" }
    get '/friends', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
  end

  test "get friends with a query parameter" do
    mock(CACHE).get("1_friends"){[{"name" => "hey", "id" => 1}]}
    mock(CACHE).get("1_something").twice { "something" }
    get '/friends', {:q => 'hey'}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert last_response.body == "hey|1"
  end

  test "get friends_history" do
    mock(CACHE).get("2_1"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").times(3) { "something" }
    get '/friends_history/2', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end

  test "get history" do
    mock(CACHE).get("1_2"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").twice { "something" }
    get '/history/2', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end

  test "get history between 2 friends" do
    mock(CACHE).get("2_3"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").twice { "something" }
    get '/history/2/3', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end

  test "get friends_comments" do
    mock(CACHE).get("2_1_comments"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").times(3) { "something" }
    get '/friends_comments/2', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end

  test "get comments" do
    mock(CACHE).get("1_2_comments"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").times(3) { "something" }
    get '/comments/2', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end

  test "get comments between 2 friends" do
    mock(CACHE).get("2_3_comments"){[{"created_time" => "1234567891"}]}
    mock(CACHE).get("1_something").twice { "something" }
    get '/comments/2/3', {}, {'rack.session' => {:user_id => 1}}
    assert last_response.ok?
    assert_equal "[{\"created_time\":\"1234567891\"}]", last_response.body
  end
end
