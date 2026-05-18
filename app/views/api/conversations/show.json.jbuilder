json.(@conversation, :id, :title, :kind, :closed, :created_at, :updated_at)
json.participants @conversation.users do |user|
  json.(user, :id, :first_name, :last_name, :role)
end
json.messages @messages do |message|
  json.(message, :id, :content, :created_at)
  json.user do
    json.(message.user, :id, :first_name, :last_name) if message.user
  end
end
