require "test_helper"

module Admin
  class BranchesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @branch_one = branches(:one)
      @branch_two = branches(:two)
    end

    test "index redirects when not authenticated" do
      get admin_branches_path
      assert_redirected_to new_session_path
    end

    test "index renders when admin" do
      sign_in_as(@admin)
      get admin_branches_path
      assert_response :success
      assert_select "h1", text: "Panel de Sedes"
    end

    test "index redirects when authenticated as non-admin" do
      sign_in_as(users(:one))
      get admin_branches_path
      assert_redirected_to root_path
    end

    test "index filters by enabled status" do
      sign_in_as(@admin)
      get admin_branches_path, params: { status: "enabled" }
      assert_response :success
      assert_select "h2", text: @branch_one.name
      assert_select "h2", text: @branch_two.name, count: 0
    end

    test "index filters by disabled status" do
      sign_in_as(@admin)
      get admin_branches_path, params: { status: "disabled" }
      assert_response :success
      assert_select "h2", text: @branch_two.name
      assert_select "h2", text: @branch_one.name, count: 0
    end

    test "index filters by query" do
      sign_in_as(@admin)
      get admin_branches_path, params: { query: "Centro" }
      assert_response :success
      assert_select "h2", text: @branch_one.name
      assert_select "h2", text: @branch_two.name, count: 0
    end

    test "index shows empty state when no results match" do
      sign_in_as(@admin)
      get admin_branches_path, params: { query: "Nonexistent" }
      assert_response :success
      assert_match /No se encontraron sedes/, response.body
    end

    test "show renders when admin" do
      sign_in_as(@admin)
      get admin_branch_path(@branch_one)
      assert_response :success
      assert_select "h1", text: @branch_one.name
    end

    test "show redirects when not staff" do
      sign_in_as(users(:one))
      get admin_branch_path(@branch_one)
      assert_redirected_to root_path
    end

    test "new renders when admin" do
      sign_in_as(@admin)
      get new_admin_branch_path
      assert_response :success
      assert_select "h1", text: "Nueva Sede"
    end

    test "new redirects when not staff" do
      sign_in_as(users(:one))
      get new_admin_branch_path
      assert_redirected_to root_path
    end

    test "create with valid data redirects to index" do
      sign_in_as(@admin)
      assert_difference("Branch.count", 1) do
        post admin_branches_path, params: {
          branch: {
            name: "Sucursal Nueva",
            address: "Av. Nueva 123",
            phone: "29009999"
          }
        }
      end
      assert_redirected_to admin_branches_path
    end

    test "create with invalid data re-renders form" do
      sign_in_as(@admin)
      assert_no_difference("Branch.count") do
        post admin_branches_path, params: {
          branch: {
            name: "",
            phone: ""
          }
        }
      end
      assert_response :unprocessable_entity
    end

    test "edit renders when admin" do
      sign_in_as(@admin)
      get edit_admin_branch_path(@branch_one)
      assert_response :success
      assert_select "h1", text: "Editar Sede"
    end

    test "edit redirects when not staff" do
      sign_in_as(users(:one))
      get edit_admin_branch_path(@branch_one)
      assert_redirected_to root_path
    end

    test "update with valid data redirects to show" do
      sign_in_as(@admin)
      patch admin_branch_path(@branch_one), params: {
        branch: { name: "Updated Name" }
      }
      assert_redirected_to admin_branch_path(@branch_one)
      assert_equal "Updated Name", @branch_one.reload.name
    end

    test "update with invalid data re-renders edit" do
      sign_in_as(@admin)
      patch admin_branch_path(@branch_one), params: {
        branch: { name: "" }
      }
      assert_response :unprocessable_entity
    end

    test "destroy removes branch" do
      sign_in_as(@admin)
      branch = Branch.create!(name: "Sucursal Temporal", address: "Temp 123", phone: "00000000")
      assert_difference("Branch.count", -1) do
        delete admin_branch_path(branch)
      end
      assert_redirected_to admin_branches_path
    end

    test "toggle_status disables an enabled branch" do
      sign_in_as(@admin)
      assert @branch_one.enabled
      patch toggle_status_admin_branch_path(@branch_one)
      assert_redirected_to admin_branches_path
      assert_not @branch_one.reload.enabled
    end

    test "toggle_status enables a disabled branch" do
      sign_in_as(@admin)
      assert_not @branch_two.enabled
      patch toggle_status_admin_branch_path(@branch_two)
      assert_redirected_to admin_branches_path
      assert @branch_two.reload.enabled
    end

    test "toggle_status redirects when not staff" do
      sign_in_as(users(:one))
      patch toggle_status_admin_branch_path(@branch_one)
      assert_redirected_to root_path
    end
  end
end
