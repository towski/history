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
    OAuth2::AccessToken.new(client, CACHE.get("#{session[:user_id]}-#{API_KEY}"))
  end

  def current_user
    session[:user_id] ? User.new(session[:user_id]) : nil
  end

  before do
    if !current_user && request.path != "/auth/facebook" && request.path != "/auth/facebook/callback"
      redirect '/auth/facebook'
    end
  end

  get '/' do
    @friends = current_user.get_friends
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
    user = JSON.parse(access_token.get('/me'))
    Cache.set("#{user["id"]}-#{API_KEY}", access_token.token)
    session[:user_id] = user["id"]
    redirect '/history/3400804'
  end

  get '/history/:id' do
    @events = current_user.get_from_facebook(params[:id])
    erb :history
  end

  get '/history/:first_id/:second_id' do
    @events = User.new(params[:first_id]).get_from_facebook(params[:second_id])
    erb :history
  end
end
