require "test_helper"

module Api
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup { @user = users(:one) }

    test "create with valid credentials returns user and session_id" do
      post api_session_path, params: { email_address: @user.email_address, password: "password" },
           headers: { "Accept" => "application/json" }
      assert_response :created
      body = response.parsed_body
      assert body.key?("user")
      assert body.key?("session_id")
      assert_equal @user.id, body["user"]["id"]
      assert_equal @user.email_address, body["user"]["email_address"]
    end

    test "create with invalid credentials returns 401" do
      post api_session_path, params: { email_address: @user.email_address, password: "wrong" },
           headers: { "Accept" => "application/json" }
      assert_response :unauthorized
      assert_equal "Email o contraseña incorrectos", response.parsed_body["error"]
    end

    test "destroy terminates session" do
      sign_in_as(@user)
      delete api_session_path, headers: { "Accept" => "application/json" }
      assert_response :ok
      assert_equal "Sesión cerrada correctamente", response.parsed_body["message"]
    end

    test "destroy without auth returns 401" do
      delete api_session_path, headers: { "Accept" => "application/json" }
      assert_response :unauthorized
    end
  end
end
