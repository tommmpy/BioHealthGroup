require "application_system_test_case"

class AdminEstudiosTest < ApplicationSystemTestCase
  setup do
    login
  end

  test "estudios index renders accordion sections" do
    visit admin_estudios_path

    assert_selector "h1", text: "Gestión de Estudios"
    assert_text "EN PROGRESO"
    assert_text "PENDIENTES"
    assert_text "FINALIZADOS"
  end

  test "navigating to new estudio form" do
    visit admin_estudios_path

    click_on "Agendar estudio"

    assert_selector "h1", text: "Agendar Estudio"
  end

  test "estudios index shows estudio cards" do
    visit admin_estudios_path

    assert_selector "div", text: /CI:/, minimum: 0
  end

  private

  def login
    visit new_session_path
    fill_in "Email", with: "admin@example.com"
    fill_in "Contraseña", with: "password"
    click_on "INGRESAR"
  end
end
