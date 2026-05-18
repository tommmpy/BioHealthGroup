require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "visiting login page renders form" do
    visit new_session_path

    assert_selector "h1", text: "Iniciar sesión"
    assert_selector "input[name='email_address']"
    assert_selector "input[name='password']"
    assert_selector "button", text: "INGRESAR"
  end

  test "login with valid credentials redirects to home" do
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Contraseña", with: "password"
    click_on "INGRESAR"

    assert_current_path root_path
    assert_text "Has iniciado sesión"
  end

  test "login with invalid credentials shows error" do
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Contraseña", with: "wrongpassword"
    click_on "INGRESAR"

    assert_selector "h1", text: "Iniciar sesión"
    assert_text "Email o contraseña incorrectos"
  end

  test "visiting password reset page" do
    visit new_password_path

    assert_selector "h1", text: "Recuperar contraseña"
    assert_selector "input[name='email_address']"
  end

  test "logging out destroys session" do
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Contraseña", with: "password"
    click_on "INGRESAR"

    assert_current_path root_path

    click_on "Cerrar sesión"

    assert_current_path new_session_path
  end
end
