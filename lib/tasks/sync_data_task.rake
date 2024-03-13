namespace :sync_data_task do
  task remove: :environment do
    FileManager.destroy_all
    p 'remove success!'
  end

  task sync: :environment do
    SyncServices.call
    p 'sync_data_task success!'
  end
end
