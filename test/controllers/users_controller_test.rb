require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get role_selection" do
    get users_role_selection_url
    assert_response :success
  end

  test "should get new_client" do
    get users_new_client_url
    assert_response :success
  end

  test "should get new_coach" do
    get users_new_coach_url
    assert_response :success
  end

  test "should get create_client" do
    get users_create_client_url
    assert_response :success
  end

  test "should get create_coach" do
    get users_create_coach_url
    assert_response :success
  end
end
