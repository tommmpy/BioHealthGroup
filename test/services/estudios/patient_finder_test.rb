require "test_helper"

class Estudios::PatientFinderTest < ActiveSupport::TestCase
  def valid_ci(prefix)
    s = prefix.to_s.rjust(7, "0")
    digits = s.chars.map(&:to_i)
    weights = [ 2, 9, 8, 7, 6, 3, 4 ]
    sum = digits.each_with_index.sum { |d, i| d * weights[i] }
    check = (10 - (sum % 10)) % 10
    "#{s}#{check}"
  end

  setup do
    @paciente1 = User.create!(
      email_address: "pf.uno@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Pedro",
      last_name: "González",
      ci: valid_ci(100_001),
      phone_number: "099130001",
      address: "Calle 1",
      branch: branches(:one),
      user_type: :persona,
      role: :paciente
    )

    @paciente2 = User.create!(
      email_address: "pf.dos@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Lucía",
      last_name: "Rodríguez",
      ci: valid_ci(100_002),
      phone_number: "099130002",
      address: "Calle 2",
      branch: branches(:one),
      user_type: :persona,
      role: :paciente
    )
  end

  test "finds by first_name" do
    results = Estudios::PatientFinder.call(query: "Pedro")
    assert_includes results.map(&:first_name), "Pedro"
    assert_equal 1, results.size
  end

  test "finds by last_name" do
    results = Estudios::PatientFinder.call(query: "Rodríguez")
    assert_includes results.map(&:last_name), "Rodríguez"
    assert_equal 1, results.size
  end

  test "finds by ci" do
    results = Estudios::PatientFinder.call(query: @paciente1.ci)
    assert_includes results.map(&:id), @paciente1.id
  end

  test "finds partial match on first_name" do
    results = Estudios::PatientFinder.call(query: "Ped")
    assert_includes results.map(&:first_name), "Pedro"
  end

  test "finds multiple matches" do
    User.create!(
      email_address: "pf.tres@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Pedro",
      last_name: "Ramírez",
      ci: valid_ci(100_003),
      phone_number: "099130003",
      address: "Calle 3",
      branch: branches(:one),
      user_type: :persona,
      role: :paciente
    )
    results = Estudios::PatientFinder.call(query: "Pedro")
    assert_equal 2, results.size
  end

  test "returns max 10 results" do
    %w[Ana Beatriz Carlos Diana Eduardo Fernanda Gabriel Hector Irene Julia Kevin Laura].each_with_index do |name, n|
      User.create!(
        email_address: "pf.batch#{n}@test.com",
        password: "Password1",
        password_confirmation: "Password1",
        first_name: "BatchPaciente",
        last_name: name,
        ci: valid_ci(200_000 + n),
        phone_number: "099140#{n.to_s.rjust(3, "0")}",
        address: "Calle Batch #{n}",
        branch: branches(:one),
        user_type: :persona,
        role: :paciente
      )
    end
    results = Estudios::PatientFinder.call(query: "BatchPaciente")
    assert_equal 10, results.size
  end

  test "returns empty for no match" do
    results = Estudios::PatientFinder.call(query: "ZZZZNOMATCH")
    assert_empty results
  end

  test "returns empty for blank query" do
    results = Estudios::PatientFinder.call(query: "")
    assert_empty results
  end

  test "returns empty for nil query" do
    results = Estudios::PatientFinder.call(query: nil)
    assert_empty results
  end

  test "only returns pacientes, not other roles" do
    User.create!(
      email_address: "pf.not.paciente@test.com",
      password: "Password1",
      password_confirmation: "Password1",
      first_name: "Pedro",
      last_name: "Admin",
      ci: valid_ci(100_010),
      phone_number: "099130010",
      address: "Calle Admin",
      branch: branches(:one),
      user_type: :persona,
      role: :medico
    )
    results = Estudios::PatientFinder.call(query: "Pedro")
    assert_not_includes results.map(&:last_name), "Admin"
  end
end
