class Estudios::PatientFinder < ApplicationService
  def initialize(query:)
    @query = query.to_s.strip
  end

  def call
    return User.none if @query.blank?

    User.where(role: User.roles[:paciente])
        .where("first_name ILIKE :q OR last_name ILIKE :q OR ci ILIKE :q",
               q: "%#{@query}%")
        .limit(10)
        .select(:id, :first_name, :last_name, :ci, :email_address, :phone_number)
  end
end
