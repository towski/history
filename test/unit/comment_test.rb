require File.dirname(__FILE__) + "/../test_helper"

context "User" do
	test "can get comments" do
    user = User.new(1)
    access_token = user.access_token
    mock(access_token).get.twice.with_any_args { {}.to_json }
    history = Comment.fetch(user.user_id, 2, access_token)
  end
end
