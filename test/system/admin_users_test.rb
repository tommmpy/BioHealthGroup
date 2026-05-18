require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  setup do
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Contraseña", with: "password"
    click_on "INGRESAR"
  end

  test "admin users index renders role accordion sections" do
    visit admin_users_path

    assert_selector "h1", text: "Gestión de Personal"
    assert_text "ADMINISTRADORES"
    assert_text "MÉDICOS"
    assert_text "RECEPCIONISTAS"
    assert_text "PACIENTES"
  end

  test "admin users index shows user count" do
    visit admin_users_path

    assert_text "USUARIOS"
  end

  test "navigating to admin user show page" do
    visit admin_users_path

    click_on "Admin User"

    assert_selector "h1", text: "Admin User"
  end

  test "navigating to new user form" do
    visit admin_users_path

    click_on "Nuevo usuario"

    assert_selector "h1", text: "Nuevo Usuario"
    assert_selector "input[name='user[first_name]']"
  end

  test "creating a new user" do
    visit new_admin_user_path

    fill_in "Nombre(s)", with: "Carlos"
    fill_in "Apellido(s)", with: "Rodríguez"
    fill_in "Correo electrónico", with: "carlos@test.com"
    fill_in "Cédula de Identidad", with: "12345678"
    fill_in "Teléfono", with: "099999999"

    click_on "Crear Usuario"

    assert_text "Usuario creado"
    assert_current_path admin_users_path
  end
end
