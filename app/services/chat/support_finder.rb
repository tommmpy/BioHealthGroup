class Chat::SupportFinder < ApplicationService
  def call
    User.where(role: [ User.roles[:recepcionista], User.roles[:administrador] ]).first
  end
end
