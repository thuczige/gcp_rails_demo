module Cronjobs
  class SyncDataController < Cronjobs::BaseController
    def push_to_task
      verify_oidc_token! cronjobs_push_to_task_url
      url = cronjobs_execute_sync_url
      Extensions::GoogleCloud::Tasks.create(url: url, audience: url)
      head :ok
    end

    def execute_sync
      verify_oidc_token! cronjobs_execute_sync_url
      SyncServices.call

      head :ok
    end
  end
end
