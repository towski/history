class History
  def initialize(user_id, friend_id, access_token)
    @stream = Cache.get("#{user_id}_#{friend_id}") do
      self.class.fetch(user_id, friend_id, access_token)
    end
  end

  def self.fetch(user_id, friend_id, access_token)
    query = "SELECT created_time, message, actor_id, source_id, comments, likes, attachment FROM stream WHERE source_id = #{user_id} AND actor_id = #{friend_id}"
    response = access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json")
    results = JSON.parse(response)
    # if the api returns a hash, it's empty
    results = [] if results.kind_of?(Hash)
    results.sort_by{|result| -result["created_time"]}
  end

  def to_json
    @stream.to_json
  end
end
