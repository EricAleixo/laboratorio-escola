require "test_helper"

class ExamePacientesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get exame_pacientes_index_url
    assert_response :success
  end

  test "should get show" do
    get exame_pacientes_show_url
    assert_response :success
  end

  test "should get new" do
    get exame_pacientes_new_url
    assert_response :success
  end

  test "should get create" do
    get exame_pacientes_create_url
    assert_response :success
  end

  test "should get edit" do
    get exame_pacientes_edit_url
    assert_response :success
  end

  test "should get update" do
    get exame_pacientes_update_url
    assert_response :success
  end

  test "should get destroy" do
    get exame_pacientes_destroy_url
    assert_response :success
  end
end
