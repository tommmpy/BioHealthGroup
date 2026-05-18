require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new renders login page successfully" do
    get new_session_path
    assert_response :success
    assert_select "h1", text: "Iniciar sesión"
  end

  test "new redirects to root if already authenticated" do
    sign_in_as(@user)
    get new_session_path
    assert_redirected_to root_path
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "choose shows when user has existing sessions" do
    existing = @user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1",
                                      user_name: "#{@user.first_name} #{@user.last_name}")
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to choose_session_path
    get choose_session_path
    assert_response :success
    assert_select "h1", text: "Sesión activa detectada"
  end

  test "choose redirects if no pending user" do
    get choose_session_path
    assert_redirected_to new_session_path
  end

  test "recover re-activates terminated session and redirects to root" do
    @user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1",
                          user_name: "#{@user.first_name} #{@user.last_name}",
                          terminated_at: Time.current)
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to choose_session_path
    post recover_session_path
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "recover without terminated session shows alert" do
    existing = @user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1",
                                      user_name: "#{@user.first_name} #{@user.last_name}")
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to choose_session_path

    existing.update!(terminated_at: Time.current)
    post recover_session_path
    assert_redirected_to root_path
  end

  test "force_new terminates old sessions" do
    @user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1",
                           user_name: "#{@user.first_name} #{@user.last_name}")
    post session_path, params: { email_address: @user.email_address, password: "password" }
    assert_redirected_to choose_session_path
    post force_new_session_path
    assert_redirected_to root_path
    assert_equal 1, @user.sessions.active.count
  end

  test "destroy" do
    sign_in_as(@user)
    delete session_path
    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
