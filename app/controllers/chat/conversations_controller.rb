module Chat
  class ConversationsController < ApplicationController
    before_action :cleanup_empty_conversations, only: :index

    def index
      base = ->(s) { s.includes(:users, :messages) }

      if current_user.paciente?
        @support_conversations = base.call(current_user.conversations.support.prioritized)
        @system_conversations = base.call(current_user.conversations.system.ordered)
      elsif is_administrador? || is_recepcionista?
        @pending_conversations = base.call(
          Chat::Conversation.support.pending
            .joins(:users).where(users: { role: User.roles[:paciente] }).distinct.ordered
        )
        @my_chats = base.call(current_user.conversations.where(closed: false).prioritized)
        @closed_conversations = base.call(current_user.conversations.where(closed: true).prioritized)
      else
        @my_chats = base.call(current_user.conversations.where(closed: false).prioritized)
        @closed_conversations = base.call(current_user.conversations.where(closed: true).prioritized)
      end
    end

    def show
      @conversation = current_user.conversations.find(params[:id])
      cleanup_stale_empty_conversation
      @messages = @conversation.messages.ordered.includes(:user)
      @message = Chat::Message.new
    end

    def new
      @conversation = Chat::Conversation.new
    end

    def create
      if current_user.paciente? && params[:title].blank?
        redirect_to new_conversation_path, alert: "El asunto es obligatorio para crear un ticket."
        return
      end

      result = Chat::ConversationBuilder.call(
        current_user: current_user,
        recipient_id: params[:recipient_id],
        recipient_ids: params[:recipient_ids],
        title: params[:title]
      )

      if result[:success]
        redirect_to result[:conversation] ? conversation_path(result[:conversation]) : conversations_path, notice: result[:notice]
      else
        redirect_to conversations_path, alert: result[:alert]
      end
    end

    def edit
      @conversation = current_user.conversations.find(params[:id])
      unless is_administrador? || is_recepcionista?
        redirect_to conversation_path(@conversation), alert: "No tienes permiso para editar este ticket."
      end
    end

    def update
      @conversation = current_user.conversations.find(params[:id])
      unless is_administrador? || is_recepcionista?
        redirect_to conversation_path(@conversation), alert: "No tienes permiso para editar este ticket." and return
      end

      if @conversation.update(conversation_params)
        redirect_to conversation_path(@conversation), notice: "Ticket actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def close
      @conversation = current_user.conversations.find(params[:id])
      policy = ConversationPolicy.new(current_user, @conversation)

      if policy.close?
        @conversation.close!
        redirect_to conversations_path, notice: "Ticket cerrado."
      else
        redirect_to conversation_path(@conversation), alert: "No tienes permiso para cerrar este chat."
      end
    end

    def reopen
      @conversation = current_user.conversations.find(params[:id])
      unless is_administrador? || is_recepcionista?
        redirect_to conversation_path(@conversation), alert: "No tienes permiso para reabrir este ticket."
        return
      end

      @conversation.update!(closed: false)
      @conversation.clear_reopen_request!

      if @conversation.users.where.not(id: current_user.id).exists?
        NotificationService.notify_participants(
          conversation: @conversation,
          kind: "reopened",
          title: "Ticket reabierto: #{@conversation.title}",
          body: "El ticket fue reabierto por #{current_user.first_name} #{current_user.last_name}.",
          except_user: current_user
        )
      end

      redirect_to conversation_path(@conversation), notice: "Ticket reabierto."
    end

    def request_reopen
      @conversation = current_user.conversations.find(params[:id])
      unless current_user.paciente?
        redirect_to conversation_path(@conversation), alert: "No tienes permiso para solicitar reapertura."
        return
      end

      @conversation.request_reopen!

      NotificationService.notify_staff(
        kind: "reopen_request",
        title: "Solicitud de reapertura: #{@conversation.title}",
        body: "#{current_user.first_name} #{current_user.last_name} solicitó reabrir un ticket cerrado.",
        notifiable: @conversation
      )

      redirect_to conversation_path(@conversation), notice: "Solicitud de reapertura enviada. Esperando respuesta."
    end

    def destroy
      @conversation = current_user.conversations.find(params[:id])
      unless current_user.paciente?
        redirect_to conversations_path, alert: "No tienes permiso para eliminar este ticket."
        return
      end

      @conversation.destroy
      redirect_to conversations_path, notice: "Ticket eliminado."
    end

    def accept
      @conversation = Chat::Conversation.support.pending.find(params[:id])
      unless is_administrador? || is_recepcionista?
        redirect_to conversations_path, alert: "No tienes permiso para aceptar tickets."
        return
      end

      @conversation.update!(assigned_to: current_user)
      @conversation.chat_room_participants.find_or_create_by!(user: current_user)

      NotificationService.notify_participants(
        conversation: @conversation,
        kind: "ticket_accepted",
        title: "Ticket aceptado: #{@conversation.title}",
        body: "#{current_user.first_name} #{current_user.last_name} está atendiendo tu ticket.",
        except_user: current_user
      )

      redirect_to conversation_path(@conversation), notice: "Ticket aceptado. Ahora estás atendiendo este ticket."
    end

    private

    def conversation_params
      params.require(:chat_conversation).permit(:title)
    end

    def cleanup_empty_conversations
      current_user.conversations.left_joins(:messages).where(messages: { id: nil }).destroy_all
    end

    def cleanup_stale_empty_conversation
      if @conversation.messages.empty? && @conversation.created_at < 1.hour.ago
        @conversation.destroy
        redirect_to conversations_path, alert: "La conversación fue eliminada por inactividad."
      end
    end
  end
end
