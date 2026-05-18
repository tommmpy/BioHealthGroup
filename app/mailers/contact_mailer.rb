class ContactMailer < ApplicationMailer
  def contact_email(name, email, message, registered: false, chat_room_id: nil)
    @name = name
    @email = email
    @message = message
    @registered = registered
    @chat_room_id = chat_room_id
    @chat_room_url = chat_room_url(chat_room_id) if chat_room_id.present?

    attachments.inline["logo_bhg.png"] = File.read(Rails.root.join("app/assets/images/logo_bhg_email.png"))

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "alveztomas2004@gmail.com"),
      reply_to: email,
      subject: "Nuevo mensaje de contacto - #{@name} (#{@email})"
    )
  end

  private

  def chat_room_url(id)
    url = ENV.fetch("APPLICATION_URL", "http://192.168.1.4:3000")
    "#{url}/conversations/#{id}"
  end
end
