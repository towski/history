class Api < Sinatra::Base
  set :environment, :development
  enable :sessions
    
  def redirect_uri
    uri = URI.parse(request.url)
    uri.path = '/auth/facebook/callback'
    uri.query = nil
    uri.to_s
  end

  def self.client
    OAuth2::Client.new(API_KEY, SECRET_KEY, :site => 'https://graph.facebook.com')
  end

  def client
    self.class.client
  end

  def current_user
    session[:user_id] ? User.new(session[:user_id], client) : nil
  end

  def access_token
    current_user.access_token
  end

  before do
    if !current_user && request.path != "/auth/facebook" && request.path != "/auth/facebook/callback"
      redirect '/auth/facebook'
    end
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

  get '/' do
    @friends = current_user.friends
    erb :index
  end

  get '/history/:id' do
    current_user.history(params[:id]).to_json
  end

  get '/history/:first_id/:second_id' do
    History.new(first_id, second_id, current_user.access_token).to_json
  end
end
