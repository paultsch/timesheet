require 'test_helper'

class SheetsControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get sheets_update_url
    assert_response :success
  end

end
