require "test_helper"

class ExamesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exames_index_url
    assert_response :success
  end

  test "should get show" do
    get exames_show_url
    assert_response :success
  end

  test "should get new" do
    get exames_new_url
    assert_response :success
  end

  test "should get create" do
    get exames_create_url
    assert_response :success
  end

  test "should get edit" do
    get exames_edit_url
    assert_response :success
  end

  test "should get update" do
    get exames_update_url
    assert_response :success
  end

  test "should get destroy" do
    get exames_destroy_url
    assert_response :success
  end
end
