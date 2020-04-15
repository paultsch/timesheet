require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get admin" do
    get dashboards_admin_url
    assert_response :success
  end

end
