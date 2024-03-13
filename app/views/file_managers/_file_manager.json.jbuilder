json.extract! file_manager, :id, :file_name, :content, :created_at, :updated_at
json.url file_manager_url(file_manager, format: :json)
