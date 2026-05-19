class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    seed_branches_if_empty
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(user_type: :persona))
    @user.skip_contacto_root = true
    if @user.save
      start_new_session_for @user
      WelcomeMailer.welcome(@user).deliver_now
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Registration error: #{e.class}: #{e.message}"
    flash[:alert] = "Error al registrarse: #{e.message}"
    redirect_to new_registration_path
  end

  private

  def seed_branches_if_empty
    return unless Branch.count == 0

    branches_data = [
      { name: "BHG - Casa Central",  address: "Dr. José María Montero 2613, Punta Carretas",          phone: "2710 1234" },
      { name: "BHG - Carrasco",      address: "Cartagena 1642, Carrasco",                              phone: "2600 5678" },
      { name: "BHG - Solymar",       address: "Av. Real de Azúa, Solymar Sur",                         phone: "2696 4321" },
      { name: "BHG - Pando",         address: "Av. Artigas (Dr. Correch 1119), Pando",                 phone: "2292 2222" },
      { name: "BHG - Las Piedras",   address: "Aparicio Saravia 587, Las Piedras",                     phone: "2364 3333" },
      { name: "BHG - Maldonado",     address: "Av. Roosevelt y Henry Dunant, Maldonado",               phone: "4224 8888" },
      { name: "BHG - Mercedes",      address: "Cristóbal Colón 238, Mercedes",                         phone: "4532 1111" },
      { name: "BHG - Paysandú",      address: "Montecaseros 721 esq. Colón, Paysandú",                 phone: "4722 9999" },
      { name: "BHG - Minas",         address: "Juan Farina 401, Minas",                                phone: "4442 4444" },
      { name: "BHG - Rosario",       address: "Cerrito 237, Rosario",                                  phone: "4552 5555" },
      { name: "BHG - Salto",         address: "Treinta y Tres 42, Salto",                              phone: "4733 1111" },
      { name: "BHG - Melo",          address: "Mata 525, Melo",                                        phone: "4642 6666" }
    ]

    branches_data.each do |data|
      Branch.find_or_create_by!(name: data[:name]) do |b|
        b.assign_attributes(address: data[:address], phone: data[:phone], enabled: true)
      end
    end
  end

  def user_params
    params.require(:user).permit(
      :email_address,
      :password,
      :first_name,
      :last_name,
      :ci,
      :phone_number,
      :address,
      :branch_id,
      :birthday
    )
  end
end
