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
      query = "SELECT created_time, message, actor_id, source_id, comments, likes FROM stream WHERE source_id = #{user_id} AND actor_id = #{friend_id}"
      response = access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json")
      results = JSON.parse(response)
      # if the api returns a hash, it's empty
      results = [] if results1.kind_of?(Hash)
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
      results = JSON.parse(response)["data"]
      CACHE.set(key, results)
      results
    else
      results
    end
  end

  before do
    if !session[:user_id] && request.path != "/auth/facebook" && request.path != "/auth/facebook/callback"
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
    @events = get_from_facebook(session[:user_id], params[:id])
    erb :history
  end

  get '/history/:first_id/:second_id' do
    @events = get_from_facebook(params[:first_id], params[:second_id])
    erb :history
  end
end
