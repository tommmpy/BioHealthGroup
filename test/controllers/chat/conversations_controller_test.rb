require "test_helper"

module Chat
  class ConversationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @paciente = users(:one)
      @admin = users(:admin)
      @conversation = Chat::Conversation.create!(title: "Test", kind: "support")
      Chat::Participant.create!(conversation: @conversation, user: @paciente)
      Chat::Participant.create!(conversation: @conversation, user: @admin)
    end

    test "index as paciente renders their conversations" do
      sign_in_as(@paciente)
      get conversations_path
      assert_response :success
    end

    test "index as admin renders pending conversations" do
      sign_in_as(@admin)
      get conversations_path
      assert_response :success
    end

    test "show allows participant to view conversation" do
      sign_in_as(@paciente)
      get conversation_path(@conversation)
      assert_response :success
    end

    test "show denies non-participant" do
      other = users(:two)
      sign_in_as(other)
      get conversation_path(@conversation)
      assert_response :not_found
    end

    test "new renders for authenticated user" do
      sign_in_as(@paciente)
      get new_conversation_path
      assert_response :success
    end

    test "create as paciente creates support ticket" do
      sign_in_as(@paciente)
      assert_difference("Chat::Conversation.count", 1) do
        post conversations_path, params: { title: "Ayuda con estudio" }
      end
      assert_redirected_to conversation_path(Chat::Conversation.last)
    end

    test "create as paciente without title shows alert" do
      sign_in_as(@paciente)
      post conversations_path, params: { title: "" }
      assert_redirected_to new_conversation_path
    end

    test "create as staff creates conversation with patient" do
      sign_in_as(@admin)
      assert_difference("Chat::Conversation.count", 1) do
        post conversations_path, params: { recipient_id: @paciente.id, title: "Consulta" }
      end
      assert_redirected_to conversation_path(Chat::Conversation.last)
    end

    test "close as admin closes conversation" do
      sign_in_as(@admin)
      patch close_conversation_path(@conversation)
      assert_redirected_to conversations_path
      assert @conversation.reload.closed?
    end

    test "close as paciente is denied" do
      sign_in_as(@paciente)
      patch close_conversation_path(@conversation)
      assert_redirected_to conversation_path(@conversation)
      assert_not @conversation.reload.closed?
    end

    test "request_reopen as paciente works" do
      @conversation.update!(closed: true)
      sign_in_as(@paciente)
      patch request_reopen_conversation_path(@conversation)
      assert_redirected_to conversation_path(@conversation)
      assert @conversation.reload.reopen_requested_at.present?
    end

    test "request_reopen as non-paciente is denied" do
      @conversation.update!(closed: true)
      sign_in_as(@admin)
      patch request_reopen_conversation_path(@conversation)
      assert_redirected_to conversation_path(@conversation)
      assert @conversation.reload.reopen_requested_at.nil?
    end

    test "accept as admin accepts pending ticket" do
      sign_in_as(@admin)
      patch accept_conversation_path(@conversation)
      assert_redirected_to conversation_path(@conversation)
      assert_equal @admin, @conversation.reload.assigned_to
    end

    test "accept as paciente is denied" do
      sign_in_as(@paciente)
      patch accept_conversation_path(@conversation)
      assert_redirected_to conversations_path
      assert_nil @conversation.reload.assigned_to
    end
  end
end
