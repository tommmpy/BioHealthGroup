require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "valid product" do
    product = Product.new(name: "Plantar de uso diario")
    assert product.valid?
  end

  test "invalid without name" do
    product = Product.new
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "scope active" do
    Product.create!(name: "Activo")
    Product.create!(name: "Inactivo", active: false)
    assert_equal 1, Product.active.count
  end

  test "scope by_category" do
    Product.create!(name: "Plantar deportivo", category: "plantar")
    Product.create!(name: "Espuma", category: "material")
    assert_equal 1, Product.by_category("material").count
  end

  test "belongs to branch optional" do
    product = Product.new(name: "Test", branch: nil)
    assert product.valid?
  end

  test "default stock quantity is 0" do
    product = Product.create!(name: "Test")
    assert_equal 0, product.stock_quantity
  end

  test "default active is true" do
    product = Product.create!(name: "Test")
    assert product.active
  end
end
