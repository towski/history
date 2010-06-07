require File.dirname(__FILE__) + "/../test_helper"

context "User" do
	test "can get history" do
    CACHE.delete("1_2")
    user = User.new(1, Api.client)
    mock(user.access_token).get.with_any_args { {}.to_json }
    history = user.history_with(2)
  end
end
