class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.prioritized.includes(:notifiable)
    @pagy, @notifications = pagy(@notifications, limit: 30)
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    if @notification.notifiable.is_a?(Chat::Conversation)
      redirect_to conversation_path(@notification.notifiable)
    else
      redirect_to notifications_path
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back_or_to notifications_path
  end
end
