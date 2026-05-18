module Api
  class ConversationsController < BaseController
    def index
      @conversations = current_user.conversations.prioritized.includes(:users, :messages)
    end

    def show
      @conversation = current_user.conversations.includes(:users).find(params[:id])
      @messages = @conversation.messages.ordered.includes(:user)
    end

    def create
      if current_user.paciente? && params[:title].blank?
        render json: { error: "El asunto es obligatorio para crear un ticket" }, status: :unprocessable_entity
        return
      end

      result = Chat::ConversationBuilder.call(
        current_user: current_user,
        recipient_id: params[:recipient_id],
        recipient_ids: params[:recipient_ids],
        title: params[:title]
      )

      if result[:success]
        @conversation = result[:conversation]
        render :show, status: :created
      else
        render json: { error: result[:alert] }, status: :unprocessable_entity
      end
    end
  end
end
