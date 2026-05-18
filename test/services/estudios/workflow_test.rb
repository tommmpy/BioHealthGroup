require "test_helper"

class Estudios::WorkflowTest < ActiveSupport::TestCase
  setup do
    @medico = User.create!(
      email_address: "wf.medico@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Workflow",
      last_name: "Medico",
      ci: "12345672",
      phone_number: "099120001",
      address: "Calle WF 123",
      branch: branches(:one),
      user_type: :persona,
      role: :medico
    )

    @estudio = Estudio.create!(
      user: users(:one),
      nombre_completo: "Paciente Test",
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now,
      branch: branches(:one)
    )
  end

  test "iniciar sets estado to en_progreso and assigns medico" do
    result = Estudios::Workflow.call(@estudio, :iniciar, current_user: @medico)
    assert result[:success]
    assert @estudio.reload.en_progreso?
    assert_equal @medico.id, @estudio.medico_id
  end

  test "iniciar without current_user still succeeds but medico_id is nil" do
    result = Estudios::Workflow.call(@estudio, :iniciar)
    assert result[:success]
    assert @estudio.reload.en_progreso?
    assert_nil @estudio.medico_id
  end

  test "finalizar with metar_paciente present sets finalizado" do
    @estudio.update!(metar_paciente: "METAR-001")
    result = Estudios::Workflow.call(@estudio, :finalizar)
    assert result[:success]
    assert @estudio.reload.finalizado?
    assert_equal "Estudio finalizado correctamente. Orden de producción generada.", result[:notice]
  end

  test "finalizar without metar_paciente returns error" do
    result = Estudios::Workflow.call(@estudio, :finalizar)
    assert_not result[:success]
    assert_equal "Debe ingresar el METAR antes de finalizar el estudio.", result[:alert]
  end

  test "unknown action returns failure without alert" do
    result = Estudios::Workflow.call(@estudio, :nada)
    assert_not result[:success]
  end
end
