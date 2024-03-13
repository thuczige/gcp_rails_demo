# frozen_string_literal: true

require 'google/cloud/tasks/v2'

module Extensions
  module GoogleCloud
    class Tasks
      DEFAULT_DEADLINE = 30.minutes.to_i

      def self.create(url:, audience:, http_method: 'GET', payload: nil, queue_name: nil)
        if Rails.env.development?
          client = ::Google::Cloud::Tasks::V2::CloudTasks::Client.new do |config|
            config.endpoint = ENV.fetch('GCP_TASK_HOST')
            config.credentials = GRPC::Core::Channel.new(ENV.fetch('GCP_TASK_HOST'), nil, :this_channel_is_insecure)
          end
          url = "#{ENV.fetch('GCP_BATCH_HOST')}#{URI.parse(url).path}"
          queue_name = ENV.fetch('GCP_TASK_QUEUE')
        else
          client = ::Google::Cloud::Tasks::V2::CloudTasks::Client.new
        end

        task = ::Google::Cloud::Tasks::V2::Task.new
        oidc_token = ::Google::Cloud::Tasks::V2::OidcToken.new(service_account_email: ENV.fetch('GCP_TASK_SERVICE_EMAIL'), audience: audience)

        http_request = ::Google::Cloud::Tasks::V2::HttpRequest.new(http_method: http_method, url: url, oidc_token: oidc_token)
        http_request.body = payload if payload

        task.http_request = http_request
        task.dispatch_deadline = DEFAULT_DEADLINE

        parent = client.queue_path(project: ENV.fetch('GCP_PROJECT_ID'),
                                   location: ENV.fetch('REGION'),
                                   queue: queue_name || ENV.fetch('GCP_TASK_QUEUE'))

        client.create_task(parent: parent, task: task)
      end
    end
  end
end
