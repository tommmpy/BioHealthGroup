require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @estudio = estudios(:one)
  end

  test "should be valid with valid attributes" do
    invoice = Invoice.new(
      user: @user,
      estudio: @estudio,
      subtotal: 100.00,
      total: 122.00,
      tax_rate: 22.00,
      tax_amount: 22.00,
      due_date: 30.days.from_now
    )
    assert invoice.valid?
  end

  test "should generate invoice number before create" do
    invoice = Invoice.create!(
      user: @user,
      subtotal: 100.00,
      total: 100.00,
      due_date: 30.days.from_now
    )
    assert_match /\AFAC-\d{4}-\d{5}\z/, invoice.invoice_number
  end

  test "should require subtotal" do
    invoice = Invoice.new(
      user: @user,
      total: 100.00,
      due_date: 30.days.from_now
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:subtotal], "can't be blank"
  end

  test "should require total" do
    invoice = Invoice.new(
      user: @user,
      subtotal: 100.00,
      due_date: 30.days.from_now
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:total], "can't be blank"
  end

  test "should require due_date" do
    invoice = Invoice.new(
      user: @user,
      subtotal: 100.00,
      total: 100.00
    )
    assert_not invoice.valid?
    assert_includes invoice.errors[:due_date], "can't be blank"
  end

  test "status enum works" do
    invoice = Invoice.create!(
      user: @user,
      subtotal: 100.00,
      total: 100.00,
      due_date: 30.days.from_now
    )
    assert invoice.draft?
    assert_equal "Borrador", invoice.status_label

    invoice.sent!
    assert invoice.sent?
    assert_equal "Enviada", invoice.status_label

    invoice.paid!
    assert invoice.paid?
    assert_equal "Pagada", invoice.status_label
  end

  test "should return humanized status label" do
    invoice = Invoice.new(
      user: @user,
      subtotal: 100.00,
      total: 100.00,
      due_date: 30.days.from_now
    )
    invoice.status = :overdue
    assert_equal "Vencida", invoice.status_label
  end

  test "should have audited trail" do
    invoice = Invoice.create!(
      user: @user,
      subtotal: 100.00,
      total: 100.00,
      due_date: 30.days.from_now
    )
    assert_respond_to invoice, :audits
  end
end
