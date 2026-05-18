require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "age returns nil when birthday is blank" do
    user = users(:sin_birthday)
    assert_nil user.age
  end

  test "age returns correct integer when birthday is set" do
    user = users(:one)
    assert_kind_of Integer, user.age
    assert user.age >= 24
  end

  test "contacto_root is not required for persona 18+ without contacto_root" do
    user = User.new(
      email_address: "adulto@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Adulto",
      last_name: "Test",
      ci: "33333333",
      phone_number: "099333333",
      address: "Calle 333",
      branch: branches(:one),
      user_type: :persona,
      birthday: 25.years.ago.to_date
    )
    assert user.valid?, "Adulto sin contacto_root debe ser válido: #{user.errors.full_messages}"
  end

  test "contacto_root is required for persona under 18" do
    user = User.new(
      email_address: "menor@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Menor",
      last_name: "Test",
      ci: "44444444",
      phone_number: "099444444",
      address: "Calle 444",
      branch: branches(:one),
      user_type: :persona,
      birthday: 15.years.ago.to_date
    )
    assert_not user.valid?, "Menor sin contacto_root debe ser inválido"
    assert_includes user.errors[:contacto_root], "can't be blank"
  end

  test "contacto_root is not required for persona without birthday" do
    user = User.new(
      email_address: "sinfecha@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Sin",
      last_name: "Fecha",
      ci: "55555555",
      phone_number: "099555555",
      address: "Calle 555",
      branch: branches(:one),
      user_type: :persona
    )
    assert_not user.errors.key?(:contacto_root), "Persona sin birthday no debe requerir contacto_root"
  end

  test "contacto_root is required for empresa" do
    user = User.new(
      email_address: "empresa@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Empresa",
      last_name: "Test",
      ci: "66666666",
      phone_number: "099666666",
      address: "Calle 666",
      branch: branches(:one),
      user_type: :empresa
    )
    assert_not user.valid?, "Empresa sin contacto_root debe ser inválida"
    assert_includes user.errors[:contacto_root], "can't be blank"
  end

  test "empresa con contacto_root es válida" do
    user = User.new(
      email_address: "empresa2@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "EmpresaDos",
      last_name: "Test",
      ci: "77777777",
      phone_number: "099777777",
      address: "Calle 777",
      branch: branches(:one),
      user_type: :empresa,
      contacto_root: "Mi Empresa S.A. - 099 888 999"
    )
    assert user.valid?, "Empresa con contacto_root debe ser válida: #{user.errors.full_messages}"
  end

  test "persona under 18 with contacto_root is valid" do
    user = User.new(
      email_address: "menorvalido@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Menor",
      last_name: "Valido",
      ci: "88888888",
      phone_number: "099888888",
      address: "Calle 888",
      branch: branches(:one),
      user_type: :persona,
      birthday: 15.years.ago.to_date,
      contacto_root: "099 999 999"
    )
    assert user.valid?, "Menor con contacto_root debe ser válido: #{user.errors.full_messages}"
  end
end
