require "test_helper"

class UnidadeReferenciasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get unidade_referencias_index_url
    assert_response :success
  end

  test "should get show" do
    get unidade_referencias_show_url
    assert_response :success
  end

  test "should get new" do
    get unidade_referencias_new_url
    assert_response :success
  end

  test "should get create" do
    get unidade_referencias_create_url
    assert_response :success
  end

  test "should get edit" do
    get unidade_referencias_edit_url
    assert_response :success
  end

  test "should get update" do
    get unidade_referencias_update_url
    assert_response :success
  end

  test "should get destroy" do
    get unidade_referencias_destroy_url
    assert_response :success
  end
end
