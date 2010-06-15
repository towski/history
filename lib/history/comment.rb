class Comment
  def self.get_or_fetch(user_id, friend_id, access_token)
    Cache.get("") do
      fetch(user_id, friend_id, access_token)
    end
  end

  def self.fetch(user_id, friend_id, access_token)
    query = "select post_id from stream where source_id = #{user_id} and actor_id = #{user_id}"
    response = JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
    query = "select text, time from comment where (post_id = '" + response.map{|r| r["post_id"] }.join("' OR post_id = '") + "') AND fromid = #{friend_id}"
    results = JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
    results.map{|result| result.update "created_time" => result["time"] }
  end
end
