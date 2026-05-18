require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "new renders password reset form" do
    get new_password_path
    assert_response :success
    assert_select "h1", text: "Recuperar contraseña"
  end

  test "create redirects to login regardless of email existence" do
    post passwords_path, params: { email_address: "nonexistent@test.com" }
    assert_redirected_to new_session_path
  end

  test "create with valid email redirects to login" do
    post passwords_path, params: { email_address: users(:one).email_address }
    assert_redirected_to new_session_path
  end

  test "edit with invalid token redirects to new password" do
    get edit_password_path(token: "invalidtoken123")
    assert_redirected_to new_password_path
  end

  test "edit with valid token renders form" do
    user = users(:one)
    token = user.generate_token_for(:password_reset)
    get edit_password_path(token: token)
    assert_response :success
    assert_select "h1", text: "Actualizar contraseña"
  end

  test "update with valid token and matching passwords resets session" do
    user = users(:one)
    token = user.generate_token_for(:password_reset)

    put password_path(token: token), params: { password: "SecurePass1", password_confirmation: "SecurePass1" }
    assert_redirected_to new_session_path
  end

  test "update with invalid token redirects to new password" do
    put password_path(token: "badtoken"), params: { password: "SecurePass1", password_confirmation: "SecurePass1" }
    assert_redirected_to new_password_path
  end
end
