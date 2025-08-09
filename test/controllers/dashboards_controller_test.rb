require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get client" do
    get dashboards_client_url
    assert_response :success
  end

  test "should get coach" do
    get dashboards_coach_url
    assert_response :success
  end

  test "should get admin" do
    get dashboards_admin_url
    assert_response :success
  end
end
