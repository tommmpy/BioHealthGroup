json.array! @conversations do |conversation|
  json.(conversation, :id, :title, :kind, :closed, :created_at, :updated_at)
  json.last_message do
    if conversation.last_message
      json.(conversation.last_message, :id, :content, :created_at)
      json.user_name conversation.last_message.user&.name
    end
  end
  json.participants conversation.users do |user|
    json.(user, :id, :first_name, :last_name, :role)
  end
end
