require "test_helper"

class UnidadeMedidasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get unidade_medidas_index_url
    assert_response :success
  end

  test "should get show" do
    get unidade_medidas_show_url
    assert_response :success
  end

  test "should get new" do
    get unidade_medidas_new_url
    assert_response :success
  end

  test "should get create" do
    get unidade_medidas_create_url
    assert_response :success
  end

  test "should get edit" do
    get unidade_medidas_edit_url
    assert_response :success
  end

  test "should get update" do
    get unidade_medidas_update_url
    assert_response :success
  end

  test "should get destroy" do
    get unidade_medidas_destroy_url
    assert_response :success
  end
end
