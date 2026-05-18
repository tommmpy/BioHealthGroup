class ChatChannel < ApplicationCable::Channel
  def subscribed
    conversation = Chat::Conversation.find(params[:id])
    if conversation.users.include?(current_user)
      stream_for conversation
    else
      reject
    end
  end

  def unsubscribed
  end

  def receive(data)
    conversation = Chat::Conversation.find(data["conversation_id"])
    message = conversation.messages.build(
      user: current_user,
      content: data["content"]
    )
    if message.save
      html = ApplicationController.render(
        partial: "chat/messages/message",
        locals: { message: message, current_user: nil },
        formats: [ :html ]
      )
      ChatChannel.broadcast_to(conversation, {
        type: "new_message",
        message_id: message.id,
        html: html,
        user_id: current_user.id
      })
    end
  end
end
