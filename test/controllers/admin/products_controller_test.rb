require "test_helper"

module Admin
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    include SessionTestHelper

    setup do
      sign_in_as(users(:admin))
    end

    test "index renders" do
      get admin_products_path
      assert_response :success
      assert_select "h1", text: "Inventario de Productos"
    end

    test "new renders form" do
      get new_admin_product_path
      assert_response :success
      assert_select "h1", text: "Nuevo Producto"
    end

    test "create product" do
      assert_difference("Product.count") do
        post admin_products_path, params: { product: { name: "Plantar de uso diario", category: "plantar", unit_price: 1500 } }
      end
      assert_redirected_to admin_products_path
    end

    test "create with invalid params" do
      assert_no_difference("Product.count") do
        post admin_products_path, params: { product: { name: "" } }
      end
      assert_response :unprocessable_entity
    end

    test "edit renders form" do
      product = Product.create!(name: "Test")
      get edit_admin_product_path(product)
      assert_response :success
    end

    test "update product" do
      product = Product.create!(name: "Test")
      patch admin_product_path(product), params: { product: { name: "Updated" } }
      assert_redirected_to admin_products_path
      assert_equal "Updated", product.reload.name
    end

    test "destroy product" do
      product = Product.create!(name: "Test")
      assert_difference("Product.count", -1) do
        delete admin_product_path(product)
      end
      assert_redirected_to admin_products_path
    end

    test "non-admin cannot create" do
      sign_out
      sign_in_as(users(:one))
      get new_admin_product_path
      assert_redirected_to root_path
    end
  end
end
