Rails.application.routes.draw do
  resources :file_managers
  devise_for :users
  devise_scope :user do
    get :log_out, to: 'devise/sessions#destroy'
  end
  root "file_managers#index"

  namespace :cronjobs do
    get 'execute_sync', to: 'sync_data#execute_sync'
    get 'push_to_task', to: 'sync_data#push_to_task'
  end
end
