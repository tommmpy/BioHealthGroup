require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @conversation = Chat::Conversation.create!(title: "Test", kind: "support")
    Chat::Participant.create!(conversation: @conversation, user: @user)
  end

  test "index returns success for authenticated user" do
    sign_in_as(@user)
    get notifications_path
    assert_response :success
  end

  test "mark read marks notification as read" do
    notification = Notification.create!(user: @user, kind: "new_message", title: "Test", notifiable: @conversation)
    sign_in_as(@user)
    patch mark_read_notification_path(notification)
    assert notification.reload.read?
  end

  test "mark read redirects to conversation when notifiable is conversation" do
    notification = Notification.create!(user: @user, kind: "new_message", title: "Test", notifiable: @conversation)
    sign_in_as(@user)
    patch mark_read_notification_path(notification)
    assert_redirected_to conversation_path(@conversation)
  end

  test "mark read redirects to notifications when notifiable is not conversation" do
    notification = Notification.create!(user: @user, kind: "test", title: "Test", notifiable: @user)
    sign_in_as(@user)
    patch mark_read_notification_path(notification)
    assert_redirected_to notifications_path
  end

  test "mark all read marks all notifications as read" do
    Notification.create!(user: @user, kind: "new_message", title: "Test 1", notifiable: @conversation)
    Notification.create!(user: @user, kind: "new_message", title: "Test 2", notifiable: @conversation)
    sign_in_as(@user)
    patch mark_all_read_notifications_path
    assert_equal 0, @user.notifications.unread.count
  end
end
