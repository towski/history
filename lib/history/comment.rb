class Comment
  def self.get_or_fetch(user_id, friend_id, access_token)
    Cache.get("#{user_id}_#{friend_id}_comments") do
      fetch(user_id, friend_id, access_token)
    end
  end

  def self.fetch(user_id, friend_id, access_token)
    query1 = "SELECT created_time, message, actor_id, source_id, post_id, comments, likes, attachment FROM stream WHERE source_id = #{friend_id} AND actor_id = #{friend_id}"
    query2 = "SELECT fromid, post_id, text, time FROM comment WHERE post_id IN (SELECT post_id FROM #query1) AND fromid = #{user_id}"
    overall = "{'query1':'#{query1}','query2':'#{query2}'}"
    results = JSON.parse(access_token.get("https://api.facebook.com/method/fql.multiquery", :queries => overall, :format => "json"))
    post_data = results[0]["fql_result_set"].inject({}){|total, result| total.update result["post_id"] => result }
    results[1]["fql_result_set"].map{|result| result.update "post" => post_data[result["post_id"]] }
  end

  def self.fetch_all(user_id, friend_id, access_token)
    query1 = "SELECT created_time, message, actor_id, source_id, post_id, comments FROM stream WHERE source_id = #{friend_id} AND actor_id = #{friend_id}"
    query2 = "SELECT fromid, post_id, text, time FROM comment WHERE post_id IN (SELECT post_id FROM #query1) AND fromid = #{user_id}"
    query3 = "SELECT created_time, message, actor_id, source_id, post_id, comments FROM stream WHERE source_id = #{user_id} AND actor_id = #{user_id}"
    query4 = "SELECT fromid, post_id, text, time FROM comment WHERE post_id IN (SELECT post_id FROM #query1) AND fromid = #{friend_id}"
    overall = "{'query1':'#{query1}','query2':'#{query2}', 'query3':'#{query3}', 'query4':'#{query4}'}"
    results = JSON.parse(access_token.get("https://api.facebook.com/method/fql.multiquery", :queries => overall, :format => "json"))
    post_data = results[0]["fql_result_set"].inject({}){|total, result| total.update result["post_id"] => result }
    first_results = results[1]["fql_result_set"].map{|result| result.update "post" => post_data[result["post_id"]] }
    post_data = results[2]["fql_result_set"].inject({}){|total, result| total.update result["post_id"] => result }
    second_results = results[3]["fql_result_set"].map{|result| result.update "post" => post_data[result["post_id"]] }
    first_results + second_results
  end
end
