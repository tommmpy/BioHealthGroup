json.notifications @notifications do |notification|
  json.(notification, :id, :kind, :title, :body, :read, :created_at)
  json.notifiable_type notification.notifiable_type
  json.notifiable_id notification.notifiable_id
end
json.pagy do
  json.(@pagy, :count, :page, :prev, :next, :pages)
end
