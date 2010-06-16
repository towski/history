class Comment
  def self.get_or_fetch(user_id, friend_id, access_token)
    Cache.get("#{user_id}_#{friend_id}_comments") do
      fetch(user_id, friend_id, access_token)
    end
  end

  def self.fetch(user_id, friend_id, access_token)
    query1 = "select post_id from stream where source_id = #{friend_id} and actor_id = #{friend_id}"
    query2 = "SELECT fromid, post_id, text, time FROM comment WHERE post_id IN (SELECT post_id FROM #query1) AND fromid = #{user_id}"
    overall = "{'query1':'#{query1}','query2':'#{query2}'}"
    results = JSON.parse(access_token.get("https://api.facebook.com/method/fql.multiquery", :queries => overall, :format => "json"))
    results[1]
  end
end
    #response = JSON.parse(access_token.get("https://api.facebook.com/method/fql.query", :query => query, :format => "json"))
    #query = "select fromid, post_id, text, time from comment where (post_id = '" + response.map{|r| r["post_id"] }.join("' OR post_id = '") + "') AND fromid = #{friend_id}"
