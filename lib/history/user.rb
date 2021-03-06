class User
  attr_reader :user_id, :client

  def initialize(user_id, client = Api.client)
    @user_id = user_id
    @client = client
  end

  def history_with(friend_id)
    History.new(user_id, friend_id, access_token)
  end

  def friends
    Cache.get("#{user_id}_friends") do
      response = access_token.get("/me/friends")
      JSON.parse(response)["data"]
    end
  end

  def access_key
    @access_key ||= Cache.get("#{user_id}_#{API_KEY}")
  end

  def access_token
    OAuth2::AccessToken.new(client, access_key)
  end
end
