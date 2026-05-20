require "test_helper"

class EstudioPolicyTest < ActiveSupport::TestCase
  def valid_ci(prefix)
    s = prefix.to_s.rjust(7, "0")
    digits = s.chars.map(&:to_i)
    weights = [ 2, 9, 8, 7, 6, 3, 4 ]
    sum = digits.each_with_index.sum { |d, i| d * weights[i] }
    check = (10 - (sum % 10)) % 10
    "#{s}#{check}"
  end

  setup do
    @admin   = users(:admin)
    @recepcionista = User.create!(
      email_address: "pol.recep@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Recepcionista", last_name: "Test",
      ci: valid_ci(300_001), phone_number: "099160001",
      address: "Calle Recep", branch: branches(:one),
      user_type: :persona, role: :recepcionista, birthday: "1990-01-01"
    )
    @medico  = User.create!(
      email_address: "pol.medico@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Medico", last_name: "Principal",
      ci: valid_ci(300_002), phone_number: "099160002",
      address: "Calle Med", branch: branches(:one),
      user_type: :persona, role: :medico, birthday: "1990-01-01"
    )
    @medico_otro = User.create!(
      email_address: "pol.medico2@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Medico", last_name: "Otro",
      ci: valid_ci(300_003), phone_number: "099160003",
      address: "Calle Med2", branch: branches(:two),
      user_type: :persona, role: :medico, birthday: "1990-01-01"
    )
    @operario = User.create!(
      email_address: "pol.op@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Operario", last_name: "Test",
      ci: valid_ci(300_004), phone_number: "099160004",
      address: "Calle Op", branch: branches(:one),
      user_type: :persona, role: :operario, birthday: "1990-01-01"
    )
    @paciente = User.create!(
      email_address: "pol.pac@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Paciente", last_name: "Test",
      ci: valid_ci(300_005), phone_number: "099160005",
      address: "Calle Pac", branch: branches(:one),
      user_type: :persona, role: :paciente, birthday: "1990-01-01"
    )
    @disenador = User.create!(
      email_address: "pol.disen@test.com", password: "Password1",
      password_confirmation: "Password1",
      first_name: "Disenador", last_name: "Test",
      ci: valid_ci(300_006), phone_number: "099160006",
      address: "Calle Dis", branch: branches(:one),
      user_type: :persona, role: :disenador, birthday: "1990-01-01"
    )

    @estudio_pendiente = Estudio.create!(
      user: @paciente, nombre_completo: "Pendiente Estudio",
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now, branch: branches(:one),
      estado: :pendiente, medico: nil
    )
    @estudio_asignado = Estudio.create!(
      user: users(:one), nombre_completo: "Asignado Estudio",
      tipo_producto: [ "Plantar deportivo" ],
      fecha_estudio: Time.zone.now, branch: branches(:one),
      estado: :en_progreso, medico: @medico
    )
    @estudio_otro_medico = Estudio.create!(
      user: users(:two), nombre_completo: "Otro Medico",
      tipo_producto: [ "Plantar de niño" ],
      fecha_estudio: Time.zone.now, branch: branches(:two),
      estado: :en_progreso, medico: @medico_otro
    )
    @estudio_del_paciente = Estudio.create!(
      user: @paciente, nombre_completo: "Mi Estudio",
      tipo_producto: [ "Plantar adicional" ],
      fecha_estudio: Time.zone.now, branch: branches(:one),
      estado: :finalizado, medico: @medico,
      metar_paciente: "METAR-PAC"
    )
    @estudio_otro_paciente = Estudio.create!(
      user: users(:one), nombre_completo: "Otro Paciente",
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now, branch: branches(:one),
      estado: :pendiente, medico: nil
    )

    @all_roles = {
      administrador: @admin, recepcionista: @recepcionista,
      medico: @medico, operario: @operario,
      paciente: @paciente, disenador: @disenador
    }
  end

  # ── index? ──────────────────────────────────────────────────

  test "index? returns true for all roles" do
    @all_roles.each_value do |user|
      assert EstudioPolicy.new(user, Estudio.new).index?,
             "#{user.role} should be able to index"
    end
  end

  # ── show? ───────────────────────────────────────────────────

  test "show? allows administrador, recepcionista, operario for any estudio" do
    [ @admin, @recepcionista, @operario ].each do |user|
      policy = EstudioPolicy.new(user, @estudio_pendiente)
      assert policy.show?, "#{user.role} should be able to show any estudio"
    end
  end

  test "show? allows medico for own assigned estudio" do
    policy = EstudioPolicy.new(@medico, @estudio_asignado)
    assert policy.show?
  end

  test "show? allows medico for any pendiente estudio" do
    policy = EstudioPolicy.new(@medico, @estudio_pendiente)
    assert policy.show?
    policy2 = EstudioPolicy.new(@medico, @estudio_otro_paciente)
    assert policy2.show?
  end

  test "show? denies medico for en_progreso estudio assigned to another medico" do
    policy = EstudioPolicy.new(@medico, @estudio_otro_medico)
    assert_not policy.show?
  end

  test "show? denies medico for finalizado estudio assigned to another medico" do
    estudio_finalizado_otro = Estudio.create!(
      user: users(:one), nombre_completo: "Fin Otro",
      tipo_producto: [ "Plantar de uso diario" ],
      fecha_estudio: Time.zone.now, branch: branches(:one),
      estado: :finalizado, medico: @medico_otro,
      metar_paciente: "METAR-X"
    )
    policy = EstudioPolicy.new(@medico, estudio_finalizado_otro)
    assert_not policy.show?
  end

  test "show? allows paciente for own estudio" do
    policy = EstudioPolicy.new(@paciente, @estudio_del_paciente)
    assert policy.show?
  end

  test "show? denies paciente for another paciente estudio" do
    policy = EstudioPolicy.new(@paciente, @estudio_otro_paciente)
    assert_not policy.show?
  end

  test "show? denies disenador for any estudio" do
    policy = EstudioPolicy.new(@disenador, @estudio_pendiente)
    assert_not policy.show?
  end

  # ── new? / create? ──────────────────────────────────────────

  test "new? and create? only for administrador and recepcionista" do
    %i[administrador recepcionista].each do |role|
      user = @all_roles[role]
      assert EstudioPolicy.new(user, Estudio.new).new?,
             "#{role} should be able to new"
      assert EstudioPolicy.new(user, Estudio.new).create?,
             "#{role} should be able to create"
    end
    (%i[medico operario paciente disenador]).each do |role|
      user = @all_roles[role]
      assert_not EstudioPolicy.new(user, Estudio.new).new?,
                 "#{role} should NOT be able to new"
      assert_not EstudioPolicy.new(user, Estudio.new).create?,
                 "#{role} should NOT be able to create"
    end
  end

  # ── update? ─────────────────────────────────────────────────

  test "update? only for administrador, recepcionista, and medico" do
    %i[administrador recepcionista medico].each do |role|
      user = @all_roles[role]
      assert EstudioPolicy.new(user, @estudio_pendiente).update?,
             "#{role} should be able to update"
    end
    %i[operario paciente disenador].each do |role|
      user = @all_roles[role]
      assert_not EstudioPolicy.new(user, @estudio_pendiente).update?,
                 "#{role} should NOT be able to update"
    end
  end

  # ── edit? ──────────────────────────────────────────────────

  test "edit? only for administrador, recepcionista, and medico (same as update?)" do
    %i[administrador recepcionista medico].each do |role|
      user = @all_roles[role]
      assert EstudioPolicy.new(user, @estudio_pendiente).edit?,
             "#{role} should be able to edit"
    end
    %i[operario paciente disenador].each do |role|
      user = @all_roles[role]
      assert_not EstudioPolicy.new(user, @estudio_pendiente).edit?,
                 "#{role} should NOT be able to edit"
    end
  end

  # ── destroy? ────────────────────────────────────────────────

  test "destroy? only for administrador" do
    assert EstudioPolicy.new(@admin, @estudio_pendiente).destroy?
    (@all_roles.except(:administrador)).each_value do |user|
      assert_not EstudioPolicy.new(user, @estudio_pendiente).destroy?,
                 "#{user.role} should NOT be able to destroy"
    end
  end

  # ── iniciar? / finalizar? ──────────────────────────────────

  test "iniciar? only for administrador and medico" do
    %i[administrador medico].each do |role|
      user = @all_roles[role]
      assert EstudioPolicy.new(user, @estudio_pendiente).iniciar?,
             "#{role} should be able to iniciar"
    end
    %i[recepcionista operario paciente disenador].each do |role|
      user = @all_roles[role]
      assert_not EstudioPolicy.new(user, @estudio_pendiente).iniciar?,
                 "#{role} should NOT be able to iniciar"
    end
  end

  test "iniciar? allows medico for own assigned and pendiente estudios" do
    assert EstudioPolicy.new(@medico, @estudio_asignado).iniciar?
    assert EstudioPolicy.new(@medico, @estudio_pendiente).iniciar?
  end

  test "iniciar? allows medico for estudio assigned to another medico" do
    assert EstudioPolicy.new(@medico, @estudio_otro_medico).iniciar?
  end

  test "finalizar? only for administrador and medico" do
    %i[administrador medico].each do |role|
      user = @all_roles[role]
      assert EstudioPolicy.new(user, @estudio_pendiente).finalizar?,
             "#{role} should be able to finalizar"
    end
    %i[recepcionista operario paciente disenador].each do |role|
      user = @all_roles[role]
      assert_not EstudioPolicy.new(user, @estudio_pendiente).finalizar?,
                 "#{role} should NOT be able to finalizar"
    end
  end

  test "finalizar? allows medico for own assigned and pendiente estudios" do
    assert EstudioPolicy.new(@medico, @estudio_asignado).finalizar?
    assert EstudioPolicy.new(@medico, @estudio_pendiente).finalizar?
  end

  test "finalizar? allows medico for estudio assigned to another medico" do
    assert EstudioPolicy.new(@medico, @estudio_otro_medico).finalizar?
  end

  # ── descargar_informe? ──────────────────────────────────────

  test "descargar_informe? matches show? behavior" do
    users = [ @admin, @recepcionista, @operario, @medico,
             @medico_otro, @paciente, @disenador ]
    estudios = [ @estudio_pendiente, @estudio_asignado,
                @estudio_otro_medico, @estudio_del_paciente ]
    users.each do |user|
      estudios.each do |estudio|
        show_policy = EstudioPolicy.new(user, estudio)
        desc_policy = EstudioPolicy.new(user, estudio)
        assert_equal show_policy.show?, desc_policy.descargar_informe?,
                     "descargar_informe? should match show? for #{user.role} on estudio #{estudio.nombre_completo}"
      end
    end
  end

  # ── buscar_pacientes? ───────────────────────────────────────

  test "buscar_pacientes? returns true for all roles" do
    @all_roles.each_value do |user|
      assert EstudioPolicy.new(user, Estudio.new).buscar_pacientes?,
             "#{user.role} should be able to buscar_pacientes"
    end
  end
end
