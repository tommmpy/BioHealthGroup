class Contact::MessageHandler < ApplicationService
  def initialize(name:, email:, message:)
    @name = name
    @email = email
    @message = message
  end

  def call
    return { success: false, alert: "Todos los campos son obligatorios." } unless valid?

    registered = false
    conversation_id = nil

    user = find_user
    if user
      registered = true
      recipient = find_support_recipient
      if recipient
        conversation = find_or_create_conversation(user, recipient)
        conversation_id = conversation.id
      end
    end

    ContactMailer.contact_email(@name, @email, @message, registered: registered, chat_room_id: conversation_id).deliver_now

    { success: true, notice: "Mensaje enviado correctamente. Te contactaremos pronto." }
  end

  private

  def valid?
    @name.present? && @email.present? && @message.present?
  end

  def find_user
    User.find_by(email_address: @email)
  end

  def find_support_recipient
    Chat::SupportFinder.call
  end

  def find_or_create_conversation(user, recipient)
    existing = user.conversations.joins(:chat_room_participants)
                   .where(chat_room_participants: { user_id: recipient.id })
                   .first
    return existing if existing

    result = Chat::ConversationBuilder.call(current_user: user, recipient_id: recipient.id)
    if result[:success] && result[:conversation]
      conversation = result[:conversation]
      conversation.messages.create!(user: user, content: @message)
      conversation
    end
  end
end
