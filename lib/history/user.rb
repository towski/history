class User
  attr_reader :user_id, :client

  def initialize(user_id, client)
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

  def access_token
    @access_token ||= OAuth2::AccessToken.new(client, Cache.get("#{user_id}-#{API_KEY}"))
  end
end
