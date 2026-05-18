require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @invoice = Invoice.create!(
      user: @user,
      subtotal: 100.00,
      total: 122.00,
      tax_rate: 22.00,
      tax_amount: 22.00,
      due_date: 30.days.from_now
    )
  end

  test "should be valid with valid attributes" do
    payment = Payment.new(
      invoice: @invoice,
      amount: 122.00,
      payment_method: :cash,
      paid_at: Time.current
    )
    assert payment.valid?
  end

  test "should require amount" do
    payment = Payment.new(
      invoice: @invoice,
      paid_at: Time.current
    )
    assert_not payment.valid?
    assert_includes payment.errors[:amount], "can't be blank"
  end

  test "should require amount greater than 0" do
    payment = Payment.new(
      invoice: @invoice,
      amount: 0,
      paid_at: Time.current
    )
    assert_not payment.valid?
    assert_includes payment.errors[:amount], "must be greater than 0"
  end

  test "should require paid_at" do
    payment = Payment.new(
      invoice: @invoice,
      amount: 50.00
    )
    assert_not payment.valid?
    assert_includes payment.errors[:paid_at], "can't be blank"
  end

  test "should update invoice status to paid when fully covered" do
    Payment.create!(
      invoice: @invoice,
      amount: 122.00,
      payment_method: :transfer,
      paid_at: Time.current
    )
    @invoice.reload
    assert @invoice.paid?
    assert_not_nil @invoice.paid_at
  end

  test "should not mark invoice as paid with partial payment" do
    Payment.create!(
      invoice: @invoice,
      amount: 50.00,
      payment_method: :cash,
      paid_at: Time.current
    )
    @invoice.reload
    assert_not @invoice.paid?
  end

  test "should mark as paid after multiple payments sum to total" do
    Payment.create!(invoice: @invoice, amount: 50.00, payment_method: :cash, paid_at: Time.current)
    Payment.create!(invoice: @invoice, amount: 72.00, payment_method: :transfer, paid_at: Time.current)
    @invoice.reload
    assert @invoice.paid?
  end

  test "payment_method_label returns humanized label" do
    payment = Payment.new(payment_method: :cash)
    assert_equal "Efectivo", payment.payment_method_label

    payment = Payment.new(payment_method: :mercadopago)
    assert_equal "Mercado Pago", payment.payment_method_label
  end

  test "should have audited trail" do
    payment = Payment.create!(
      invoice: @invoice,
      amount: 122.00,
      payment_method: :card,
      paid_at: Time.current
    )
    assert_respond_to payment, :audits
  end
end
