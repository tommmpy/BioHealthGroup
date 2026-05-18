class ContactsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 30.minutes, only: :create,
    with: -> { redirect_back fallback_location: root_path, alert: "Demasiados mensajes de contacto. Intenta de nuevo más tarde." }

  def create
    result = Contact::MessageHandler.call(
      name: params[:name],
      email: params[:email],
      message: params[:message]
    )

    if result[:success]
      redirect_back fallback_location: root_path, notice: result[:notice]
    else
      redirect_back fallback_location: root_path, alert: result[:alert]
    end
  end
end
