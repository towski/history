require File.dirname(__FILE__) + "/../test_helper"

context "User" do
	test "can get comments" do
    user = User.new(1)
    access_token = user.access_token
    mock(access_token).get.with_any_args { [{"fql_result_set" => []},{"fql_result_set" => []}].to_json }
    history = Comment.fetch(user.user_id, 2, access_token)
  end

  test "results data looks correct" do
    user = User.new(1)
    access_token = user.access_token
    mock(access_token).get.with_any_args { [{"fql_result_set" => []},{"fql_result_set" => []}, {"fql_result_set" => []}, {"fql_result_set" => []} ].to_json }
    history = Comment.fetch_all(user.user_id, 2, access_token)
  end
end
