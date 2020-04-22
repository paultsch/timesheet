require 'test_helper'

class TemplatetypesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get templatetypes_new_url
    assert_response :success
  end

  test "should get create" do
    get templatetypes_create_url
    assert_response :success
  end

  test "should get index" do
    get templatetypes_index_url
    assert_response :success
  end

  test "should get edit" do
    get templatetypes_edit_url
    assert_response :success
  end

  test "should get update" do
    get templatetypes_update_url
    assert_response :success
  end

  test "should get destory" do
    get templatetypes_destory_url
    assert_response :success
  end

end
