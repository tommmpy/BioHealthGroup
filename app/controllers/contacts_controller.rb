class ContactsController < ApplicationController
  allow_unauthenticated_access

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
