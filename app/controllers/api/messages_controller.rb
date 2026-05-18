module Api
  class MessagesController < BaseController
    def create
      @conversation = current_user.conversations.find(params[:conversation_id])
      @message = @conversation.messages.build(
        user: current_user,
        content: message_params[:content]
      )

      if @message.save
        render json: {
          id: @message.id,
          content: @message.content,
          user_id: @message.user_id,
          user_name: @message.user.name,
          created_at: @message.created_at
        }, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def message_params
      params.require(:message).permit(:content)
    end
  end
end
