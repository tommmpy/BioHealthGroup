require "test_helper"

module Api
  class EstudiosControllerTest < ActionDispatch::IntegrationTest
    setup do
      @paciente = users(:one)
      @admin = users(:admin)
    end

    test "index as paciente returns their estudios" do
      sign_in_as(@paciente)
      get api_estudios_path, headers: { "Accept" => "application/json" }
      assert_response :ok
      body = response.parsed_body
      assert body.is_a?(Array)
      body.each do |e|
        assert_equal @paciente.id, e["paciente"]["id"]
      end
    end

    test "index as admin returns all estudios" do
      sign_in_as(@admin)
      get api_estudios_path, headers: { "Accept" => "application/json" }
      assert_response :ok
      body = response.parsed_body
      assert body.is_a?(Array)
      assert_equal Estudio.count, body.size
    end

    test "show as paciente returns estudio" do
      sign_in_as(@paciente)
      estudio = @paciente.estudios.first
      get api_estudio_path(estudio), headers: { "Accept" => "application/json" }
      assert_response :ok
      assert_equal estudio.id, response.parsed_body["id"]
    end

    test "show as paciente for otro paciente estudio returns 404" do
      sign_in_as(@paciente)
      otro_estudio = estudios(:two)
      get api_estudio_path(otro_estudio), headers: { "Accept" => "application/json" }
      assert_response :not_found
    end

    test "show as admin for any estudio returns it" do
      sign_in_as(@admin)
      estudio = estudios(:two)
      get api_estudio_path(estudio), headers: { "Accept" => "application/json" }
      assert_response :ok
      assert_equal estudio.id, response.parsed_body["id"]
    end

    test "unauthenticated access returns 401" do
      get api_estudios_path, headers: { "Accept" => "application/json" }
      assert_response :unauthorized
    end
  end
end
