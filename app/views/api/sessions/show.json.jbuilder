json.user do
  json.(@user, :id, :email_address, :first_name, :last_name, :ci, :phone_number, :role, :user_type, :status)
  json.name @user.name
end
json.session_id @session.id
