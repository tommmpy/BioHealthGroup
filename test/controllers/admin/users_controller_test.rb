require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @branch = branches(:one)
    end

    test "index redirects when not authenticated" do
      get admin_users_path
      assert_redirected_to new_session_path
    end

    test "index redirects when not admin" do
      sign_in_as(users(:one))
      get admin_users_path
      assert_redirected_to root_path
    end

    test "index renders when admin" do
      sign_in_as(@admin)
      get admin_users_path
      assert_response :success
      assert_select "h1", text: "Gestión de Personal"
    end

    test "new renders form when admin" do
      sign_in_as(@admin)
      get new_admin_user_path
      assert_response :success
      assert_select "h1", text: "Nuevo Usuario"
    end

    test "create with valid data redirects to index" do
      sign_in_as(@admin)
      assert_difference("User.count", 1) do
        post admin_users_path, params: {
          user: {
            email_address: "nuevo_admin@test.com",
            password: "Password1",
            first_name: "Nuevo",
            last_name: "Admin",
            ci: "99999999",
            phone_number: "099999999",
            address: "Calle Admin 789",
            branch_id: @branch.id,
            user_type: :persona,
            role: :paciente
          }
        }
      end
      assert_redirected_to admin_users_path
    end

    test "create with invalid data re-renders form" do
      sign_in_as(@admin)
      assert_no_difference("User.count") do
        post admin_users_path, params: {
          user: {
            email_address: "",
            password: "",
            first_name: "",
            last_name: ""
          }
        }
      end
      assert_response :unprocessable_entity
    end

    test "edit renders form when admin" do
      sign_in_as(@admin)
      get edit_admin_user_path(users(:one))
      assert_response :success
      assert_select "h1", text: "Editar Usuario"
    end

    test "update with valid data redirects to index" do
      sign_in_as(@admin)
      user = users(:one)
      patch admin_user_path(user), params: {
        user: { first_name: "UpdatedName" }
      }
      assert_redirected_to admin_users_path
      assert_equal "UpdatedName", user.reload.first_name
    end

    test "update with invalid data re-renders edit" do
      sign_in_as(@admin)
      patch admin_user_path(users(:one)), params: {
        user: { first_name: "" }
      }
      assert_response :unprocessable_entity
    end

    test "destroy removes user" do
      sign_in_as(@admin)
      user = users(:sin_birthday)
      assert_difference("User.count", -1) do
        delete admin_user_path(user)
      end
      assert_redirected_to admin_users_path
    end

    test "cannot destroy own account" do
      sign_in_as(@admin)
      assert_no_difference("User.count") do
        delete admin_user_path(@admin)
      end
      assert_redirected_to admin_users_path
    end
  end
end
