class Chat::ConversationBuilder < ApplicationService
  def initialize(current_user:, recipient_id: nil, title: nil, recipient_ids: nil)
    @current_user = current_user
    @recipient_id = recipient_id
    @recipient_ids = recipient_ids
    @title = title
  end

  def call
    if @current_user.paciente?
      create_for_patient
    else
      create_for_staff
    end
  end

  private

  def create_for_patient
    conversation_title = @title.presence || "Soporte - #{@current_user.first_name} #{@current_user.last_name}"
    conversation = build_conversation(title: conversation_title, kind: "support", users: [ @current_user ])
    save_result(conversation)
  end

  def create_for_staff
    ids = @recipient_ids.presence || [ @recipient_id ].compact
    return { success: false, conversation: nil, alert: "Debes seleccionar al menos un usuario." } if ids.empty?

    recipients = User.where(id: ids)
    return { success: false, conversation: nil, alert: "Usuario(s) no encontrado(s)." } if recipients.empty?

    participants = [ @current_user ] + recipients.to_a
    pacientes = participants.select(&:paciente?)

    if pacientes.size > 1
      return { success: false, conversation: nil, alert: "Solo puede haber un paciente por conversación." }
    end

    is_staff_only = pacientes.empty?
    kind = is_staff_only ? "group" : "support"

    name_suffix = participants.map { |u| "#{u.first_name} #{u.last_name}" }.join(" & ")
    conversation_title = @title.presence || "Chat: #{name_suffix}"

    conversation = build_conversation(title: conversation_title, kind: kind, users: participants)

    if is_staff_only
      { success: true, conversation: conversation, notice: "Grupo creado." }
    else
      save_result(conversation)
    end
  end

  def build_conversation(title:, kind:, users:)
    conversation = Chat::Conversation.new(title: title, kind: kind)
    conversation.save!
    users.each do |user|
      Chat::Participant.create!(conversation: conversation, user: user)
    end
    conversation
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    conversation&.errors&.add(:base, e.message) if conversation
    conversation
  end

  def save_result(conversation)
    return { success: false, conversation: nil, alert: conversation.errors.full_messages.join(", ") } if conversation.errors.any?

    NotificationService.notify_staff(
      kind: "new_ticket",
      title: "Nuevo ticket: #{conversation.title}",
      body: "#{@current_user.first_name} #{@current_user.last_name} creó un nuevo ticket de soporte.",
      notifiable: conversation
    ) if @current_user.paciente?

    { success: true, conversation: conversation, notice: "Ticket creado. Un operador lo atenderá en breve." }
  end
end
