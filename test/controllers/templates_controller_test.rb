require 'test_helper'

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get templates_new_url
    assert_response :success
  end

  test "should get edit" do
    get templates_edit_url
    assert_response :success
  end

end
