require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders registration form" do
    get new_registration_path
    assert_response :success
    assert_select "h1", text: "Crear cuenta"
  end

  test "create with valid data redirects and starts session" do
    post registrations_path, params: {
      user: {
        email_address: "nuevo@test.com",
        password: "Password1",
        first_name: "Nuevo",
        last_name: "Usuario",
        ci: "33333333",
        phone_number: "099333333",
        address: "Calle Nueva 123",
        branch_id: branches(:one).id,
        birthday: "2000-06-15",
        contacto_root: ""
      }
    }
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid data re-renders form" do
    post registrations_path, params: {
      user: {
        email_address: "",
        password: "short",
        first_name: "",
        last_name: "",
        ci: "",
        phone_number: "",
        address: "",
        branch_id: branches(:one).id
      }
    }
    assert_response :unprocessable_entity
    assert_select "h1", text: "Crear cuenta"
  end

  test "create sets user_type to persona" do
    post registrations_path, params: {
      user: {
        email_address: "persona@test.com",
        password: "Password1",
        first_name: "Solo",
        last_name: "Persona",
        ci: "44444444",
        phone_number: "099444444",
        address: "Calle 444",
        branch_id: branches(:one).id,
        birthday: "2000-06-15"
      }
    }
    assert_redirected_to root_path
    assert_equal "persona", User.find_by(email_address: "persona@test.com").user_type
  end
end
