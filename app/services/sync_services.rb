require 'google/cloud/storage'

class SyncServices
  class << self
    def call
      storage = Google::Cloud::Storage.new(project_id: ENV.fetch('GCP_PROJECT_ID', 'zigexn-vn-sandbox'))
      bucket = storage.bucket 'gcp_rails_demo'
      files = bucket.files

      files.each do |file|
        next if FileManager.find_by_file_name(file.name).present?

        downloaded = file.download
        FileManager.create(file_name: file.name, content: downloaded.read)
      end
    end
  end
end
