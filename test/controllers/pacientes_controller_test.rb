require "test_helper"

class PacientesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pacientes_index_url
    assert_response :success
  end

  test "should get show" do
    get pacientes_show_url
    assert_response :success
  end

  test "should get new" do
    get pacientes_new_url
    assert_response :success
  end

  test "should get create" do
    get pacientes_create_url
    assert_response :success
  end

  test "should get edit" do
    get pacientes_edit_url
    assert_response :success
  end

  test "should get update" do
    get pacientes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get pacientes_destroy_url
    assert_response :success
  end
end
