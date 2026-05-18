class WelcomeMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail subject: "Bienvenido a BioHealthGroup", to: user.email_address
  end
end
