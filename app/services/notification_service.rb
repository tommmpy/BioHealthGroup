class NotificationService
  def initialize(kind:, title:, user:, body: nil, notifiable: nil)
    @kind = kind
    @title = title
    @user = user
    @body = body
    @notifiable = notifiable
  end

  def call
    notification = Notification.create!(
      kind: @kind,
      title: @title,
      body: @body,
      user: @user,
      notifiable: @notifiable
    )

    pref = @user.notification_preference
    if pref&.email_notifications?
      NotificationMailer.notification_email(notification).deliver_later
    end

    NotificationChannel.broadcast_to(@user, {
      type: "new_notification",
      notification_id: notification.id,
      unread_count: @user.notifications.unread.count,
      title: @title,
      kind: @kind,
      body: @body
    })

    notification
  end

  def self.notify_staff(kind:, title:, body: nil, notifiable: nil)
    staff_roles = %w[administrador recepcionista medico operario disenador]
    User.where(role: staff_roles.map { |r| User.roles[r.to_sym] })
        .where.not(status: User::STATUSES[:no_molestar])
        .find_each do |user|
      new(kind: kind, title: title, body: body, user: user, notifiable: notifiable).call
    end
  end

  def self.notify_participants(conversation:, kind:, title:, body: nil, except_user: nil)
    conversation.users
                .where.not(id: except_user&.id)
                .where.not(status: User::STATUSES[:no_molestar])
                .find_each do |user|
      new(kind: kind, title: title, body: body, user: user, notifiable: conversation).call
    end
  end
end
