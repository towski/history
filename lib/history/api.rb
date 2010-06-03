class Api < Sinatra::Base
  set :environment, :development
  enable :sessions
    
  def redirect_uri
    uri = URI.parse(request.url)
    uri.path = '/auth/facebook/callback'
    uri.query = nil
    uri.to_s
  end

  def client
    OAuth2::Client.new(API_KEY, SECRET_KEY, :site => 'https://graph.facebook.com')
  end

  def access_token
    OAuth2::AccessToken.new(client, session[:access_token])
  end

  def get_from_facebook(user_id, friend_id)
    key = "#{user_id}_#{friend_id}"
    results = CACHE.get(key)
    if !results
      query1 = "SELECT created_time, message, actor_id FROM stream WHERE source_id = #{user_id} AND actor_id = #{friend_id}"
      response = access_token.get("https://api.facebook.com/method/fql.query", :query => query1, :format => "json")
      results1 = JSON.parse(response)
      query2 = "SELECT created_time, message, actor_id FROM stream WHERE source_id = #{friend_id} AND actor_id = #{user_id}"
      response = access_token.get("https://api.facebook.com/method/fql.query", :query => query2, :format => "json")
      results2 = JSON.parse(response)
      results = results1 + results2
      results = results.sort_by{|result| -result["created_time"]}
      CACHE.set(key, results)
      results
    else
      results
    end
  end

  def get_friends(user_id)
    key = "#{user_id}_friends"
    results = CACHE.get(key)
    if !results
      response = access_token.get("/me/friends")
      results = JSON.parse(response)
      CACHE.set(key, results)
      results
    else
      results
    end
  end

  before do
    if !session[:user_id] && request.path != "/auth/facebook"
      redirect '/auth/facebook'
    end
  end

  get '/' do
    @friends = get_friends(session[:user_id])
    erb :index
  end

  get '/auth/facebook' do
    redirect client.web_server.authorize_url(
      :redirect_uri => redirect_uri,
      :scope => 'read_stream,read_friendlists'
    )
  end

  get '/auth/facebook/callback' do
    access_token = client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
    session[:access_token] = access_token.token
    user = JSON.parse(access_token.get('/me'))
    session[:user_id] = user["id"]
    redirect '/history/3400804'
  end

  get '/history/:id' do
    get_from_facebook(session[:user_id], params[:id]).inspect
  end
end
