class User
  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def get_from_facebook(friend_id)
    Cache.cache("#{user_id}_#{friend_id}") do
      query = "SELECT created_time, message, actor_id, source_id, comments, likes FROM stream WHERE source_id = #{user_id} AND actor_id = #{friend_id}"
      response = access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json")
      results = JSON.parse(response)
      # if the api returns a hash, it's empty
      results = [] if results.kind_of?(Hash)
      results.sort_by{|result| -result["created_time"]}
    end
  end

  def get_friends
    Cache.get("#{user_id}_friends") do
      response = access_token.get("/me/friends")
      JSON.parse(response)["data"]
    end
  end

end
