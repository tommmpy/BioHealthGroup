require "test_helper"

module Admin
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    include SessionTestHelper

    setup do
      sign_in_as(users(:admin))
    end

    test "index renders" do
      get admin_appointments_path
      assert_response :success
      assert_select "h1", text: "Gestión de Turnos"
    end

    test "index shows appointment cards" do
      get admin_appointments_path
      assert_response :success
      assert_select "span", text: Appointment.first.title
    end

    test "paciente only sees own appointments" do
      sign_out
      sign_in_as(users(:one))
      get admin_appointments_path
      assert_response :success
    end

    test "medico sees relevant appointments" do
      sign_out
      sign_in_as(users(:two))
      medico = users(:two)
      medico.update!(role: User::ROLES[:medico])
      get admin_appointments_path
      assert_response :success
    end

    test "new renders" do
      get new_admin_appointment_path
      assert_response :success
    end

    test "create creates appointment" do
      assert_difference("Appointment.count") do
        post admin_appointments_path, params: {
          appointment: {
            user_id: users(:one).id,
            branch_id: branches(:one).id,
            title: "Nuevo turno",
            starts_at: 2.days.from_now.change(hour: 9),
            ends_at: 2.days.from_now.change(hour: 10)
          }
        }
      end
      assert_redirected_to admin_appointments_path
    end

    test "show renders" do
      get admin_appointment_path(appointments(:one))
      assert_response :success
    end

    test "edit renders" do
      get edit_admin_appointment_path(appointments(:one))
      assert_response :success
    end

    test "update updates appointment" do
      patch admin_appointment_path(appointments(:one)), params: {
        appointment: { title: "Title Updated" }
      }
      assert_redirected_to admin_appointment_path(appointments(:one))
      assert_equal "Title Updated", appointments(:one).reload.title
    end

    test "destroy destroys appointment" do
      assert_difference("Appointment.count", -1) do
        delete admin_appointment_path(appointments(:one))
      end
      assert_redirected_to admin_appointments_path
    end

    test "confirm confirms appointment" do
      patch confirm_admin_appointment_path(appointments(:one))
      assert_redirected_to admin_appointment_path(appointments(:one))
      assert appointments(:one).reload.confirmed?
    end

    test "cancel cancels appointment" do
      patch cancel_admin_appointment_path(appointments(:one))
      assert_redirected_to admin_appointments_path
      assert appointments(:one).reload.cancelled?
    end

    test "recepcionista can create" do
      sign_out
      recepcionista = users(:one)
      recepcionista.update!(role: User::ROLES[:recepcionista])
      sign_in_as(recepcionista)

      get new_admin_appointment_path
      assert_response :success

      assert_difference("Appointment.count") do
        post admin_appointments_path, params: {
          appointment: {
            user_id: users(:one).id,
            branch_id: branches(:one).id,
            title: "Turno de recepcionista",
            starts_at: 2.days.from_now.change(hour: 11),
            ends_at: 2.days.from_now.change(hour: 12)
          }
        }
      end
      assert_redirected_to admin_appointments_path
    end

    test "paciente cannot create" do
      sign_out
      sign_in_as(users(:one))

      get new_admin_appointment_path
      assert_redirected_to root_path

      assert_no_difference("Appointment.count") do
        post admin_appointments_path, params: {
          appointment: {
            user_id: users(:one).id,
            branch_id: branches(:one).id,
            title: "Should not create",
            starts_at: 2.days.from_now.change(hour: 9),
            ends_at: 2.days.from_now.change(hour: 10)
          }
        }
      end
    end
  end
end
