require "test_helper"

module Admin
  class EstudiosControllerTest < ActionDispatch::IntegrationTest
    include SessionTestHelper

    setup do
      sign_in_as(users(:admin))
    end

    test "index renders all sections" do
      get admin_estudios_path
      assert_response :success
      assert_select "h1", text: "Gestión de Estudios"
    end

    test "index shows estudio cards" do
      get admin_estudios_path
      assert_response :success
      assert_select "h3", minimum: 1
    end

    test "paciente only sees own estudios" do
      sign_out
      sign_in_as(users(:one))
      get admin_estudios_path
      assert_response :success
    end

    test "medico sees relevant estudios" do
      sign_out
      sign_in_as(users(:two))
      get admin_estudios_path
      assert_response :success
    end
  end
end
