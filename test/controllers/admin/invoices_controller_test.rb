require "test_helper"

module Admin
  class InvoicesControllerTest < ActionDispatch::IntegrationTest
    include SessionTestHelper

    setup do
      sign_in_as(users(:admin))
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

    test "index renders successfully" do
      get admin_invoices_path
      assert_response :success
      assert_select "h1", text: "Facturación"
    end

    test "index shows invoice rows" do
      get admin_invoices_path
      assert_response :success
      assert_match @invoice.invoice_number, response.body
    end

    test "show renders invoice details" do
      get admin_invoice_path(@invoice)
      assert_response :success
      assert_match @invoice.invoice_number, response.body
    end

    test "new renders form" do
      get new_admin_invoice_path
      assert_response :success
      assert_select "h1", text: "Nueva factura"
    end

    test "create creates invoice" do
      assert_difference("Invoice.count") do
        post admin_invoices_path, params: {
          invoice: {
            user_id: @user.id,
            subtotal: 200.00,
            total: 244.00,
            tax_rate: 22.00,
            tax_amount: 44.00,
            due_date: 30.days.from_now
          }
        }
      end
      assert_redirected_to admin_invoice_path(Invoice.last)
    end

    test "create with invalid data re-renders form" do
      assert_no_difference("Invoice.count") do
        post admin_invoices_path, params: {
          invoice: {
            user_id: @user.id,
            subtotal: nil,
            total: 100.00,
            due_date: 30.days.from_now
          }
        }
      end
      assert_response :unprocessable_entity
    end

    test "mark_sent updates status to sent" do
      patch mark_sent_admin_invoice_path(@invoice)
      assert_redirected_to admin_invoice_path(@invoice)
      @invoice.reload
      assert @invoice.sent?
    end

    test "mark_paid updates status to paid" do
      patch mark_paid_admin_invoice_path(@invoice)
      assert_redirected_to admin_invoice_path(@invoice)
      @invoice.reload
      assert @invoice.paid?
      assert_not_nil @invoice.paid_at
    end

    test "download_pdf returns PDF" do
      get download_pdf_admin_invoice_path(@invoice)
      assert_response :success
      assert_equal "application/pdf", response.content_type
    end
  end
end
