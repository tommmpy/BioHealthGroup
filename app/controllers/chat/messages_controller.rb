module Chat
  class MessagesController < ApplicationController
    def create
      @conversation = current_user.conversations.find(params[:conversation_id])
      @message = @conversation.messages.build(
        user: current_user,
        content: params.require(:message).permit(:content)[:content]
      )

      if @message.save
        html = render_to_string(partial: "chat/messages/message", locals: { message: @message, current_user: nil })
        ChatChannel.broadcast_to(@conversation, {
          type: "new_message",
          message_id: @message.id,
          html: html,
          user_id: current_user.id
        })

        NotificationService.notify_participants(
          conversation: @conversation,
          kind: "new_message",
          title: "Nuevo mensaje en #{@conversation.title}",
          body: @message.content.truncate(80),
          except_user: current_user
        )
        redirect_to conversation_path(@conversation, anchor: "message-#{@message.id}")
      else
        @messages = @conversation.messages.ordered.includes(:user)
        render "chat/conversations/show", status: :unprocessable_entity
      end
    end
  end
end
