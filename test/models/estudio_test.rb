require "test_helper"

class EstudioTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @branch = branches(:one)
  end

  test "valid estudio with required fields" do
    estudio = Estudio.new(
      user: @user,
      nombre_completo: "Juan Pérez",
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now,
      branch: @branch
    )
    assert estudio.valid?, estudio.errors.full_messages.to_s
  end

  test "invalid without nombre_completo" do
    estudio = Estudio.new(
      user: @user,
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now,
      branch: @branch
    )
    assert_not estudio.valid?
    assert_includes estudio.errors[:nombre_completo], "can't be blank"
  end

  test "invalid without fecha_estudio" do
    estudio = Estudio.new(
      user: @user,
      nombre_completo: "Juan Pérez",
      tipo_producto: [ "Plantar de uso diario" ],
      branch: @branch
    )
    assert_not estudio.valid?
    assert_includes estudio.errors[:fecha_estudio], "can't be blank"
  end

  test "calculates cantidad_productos from tipo_producto array" do
    estudio = Estudio.new(
      user: @user,
      nombre_completo: "Juan Pérez",
      tipo_producto: [ "Plantar de uso diario", "Plantar adicional" ],
      fecha_estudio: Time.zone.now,
      branch: @branch
    )
    estudio.valid?
    assert_equal 2, estudio.cantidad_productos
  end

  test "invalid if finalizado and metar_paciente is blank" do
    estudio = estudios(:one)
    estudio.estado = :finalizado
    estudio.metar_paciente = nil
    assert_not estudio.valid?
    assert estudio.errors[:metar_paciente].any?
  end

  test "valid if finalizado and metar_paciente present" do
    estudio = estudios(:one)
    estudio.estado = :finalizado
    estudio.metar_paciente = "METAR-XYZ"
    assert estudio.valid?, estudio.errors.full_messages.to_s
  end

  test "defaults to pendiente estado" do
    estudio = Estudio.new
    assert_equal "pendiente", estudio.estado
  end
end
