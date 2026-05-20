require "test_helper"

class ProductionOrderTest < ActiveSupport::TestCase
  setup do
    @estudio = estudios(:one)
  end

  test "valid production order" do
    order = ProductionOrder.new(estudio: @estudio)
    assert order.valid?
  end

  test "requires estudio" do
    order = ProductionOrder.new
    assert_not order.valid?
    assert_includes order.errors[:estudio], "must exist"
  end

  test "default status is awaiting_payment" do
    order = ProductionOrder.create!(estudio: @estudio)
    assert order.awaiting_payment?
  end

  test "status enum" do
    order = ProductionOrder.create!(estudio: @estudio)
    assert order.awaiting_payment?
    order.pending!
    assert order.pending?
    order.in_progress!
    assert order.in_progress?
    order.completed!
    assert order.completed?
    order.cancelled!
    assert order.cancelled?
  end

  test "pending scope" do
    ProductionOrder.create!(estudio: @estudio, status: :pending)
    ProductionOrder.create!(estudio: @estudio, status: :in_progress)
    ProductionOrder.create!(estudio: @estudio, status: :completed)
    assert_equal 1, ProductionOrder.pending.count
  end

  test "assigned_to is optional" do
    order = ProductionOrder.new(estudio: @estudio, assigned_to: nil)
    assert order.valid?
  end

  test "audited" do
    order = ProductionOrder.create!(estudio: @estudio)
    assert_respond_to order, :audits
  end
end
