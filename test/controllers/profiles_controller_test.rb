require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "show redirects to login when not authenticated" do
    get profile_path
    assert_redirected_to new_session_path
  end

  test "show renders profile when authenticated" do
    sign_in_as(users(:one))
    get profile_path
    assert_response :success
    assert_select "h1", text: "Configuración de cuenta"
  end

  test "edit redirects when not authenticated" do
    get edit_profile_path
    assert_redirected_to new_session_path
  end

  test "edit renders form when authenticated" do
    sign_in_as(users(:one))
    get edit_profile_path
    assert_response :success
    assert_select "h1", text: "Editar Perfil"
  end

  test "update with valid data redirects to profile" do
    sign_in_as(users(:one))
    patch profile_path, params: {
      user: {
        first_name: "JuanUpdated",
        last_name: "Pérez",
        email_address: "one@example.com",
        phone_number: "099123456",
        address: "Nueva dirección 456",
        branch_id: branches(:one).id
      }
    }
    assert_redirected_to profile_path
    assert_equal "JuanUpdated", users(:one).reload.first_name
  end

  test "update with invalid data re-renders edit" do
    sign_in_as(users(:one))
    patch profile_path, params: {
      user: {
        first_name: "",
        email_address: ""
      }
    }
    assert_response :unprocessable_entity
    assert_select "h1", text: "Editar Perfil"
  end

  test "show displays contacto_root only when present" do
    sign_in_as(users(:one))
    get profile_path
    assert_response :success
    assert_select "div", text: /Contacto emergencia/, count: 0

    sign_in_as(users(:two))
    get profile_path
    assert_response :success
    assert_select "div", text: "Empresa / Razón social"
  end
end
