require 'test_helper'

class UsertypesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get usertypes_new_url
    assert_response :success
  end

  test "should get edit" do
    get usertypes_edit_url
    assert_response :success
  end

  test "should get index" do
    get usertypes_index_url
    assert_response :success
  end

end
