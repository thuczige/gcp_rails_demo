require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GcpRailsDemo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.paths.add 'lib', eager_load: true
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    if Rails.env.development? || Rails.env.test?
      config.session_store(
        :redis_store,
        servers: ENV.fetch('REDIS_SESSION_URL'),
        expire_after: 15.days,
        key: '_gcp_rails_demo_session'
      )

      config.cache_store = :redis_cache_store, {
        driver: :hiredis,
        timeout: 30,
        url: ENV.fetch('REDIS_CACHE_URL')
      }
    else
      config.cache_store = :redis_cache_store, {
        :host => ENV.fetch('REDIS_HOST'),
        :port => ENV.fetch('REDIS_PORT'),
        :username => ENV.fetch('REDIS_USERNAME'),
        :password => ENV.fetch('REDIS_AUTH_STRING'),
        :ssl => :true,
        :db => 2,
        :driver => :ruby,
      }
      config.session_store(
        :redis_store,
        servers: [
          {
            host: ENV.fetch('REDIS_HOST'),
            port: ENV.fetch('REDIS_PORT'),
            db: 3,
            username: ENV.fetch('REDIS_USERNAME'),
            password: ENV.fetch('REDIS_AUTH_STRING'),
            ssl: true,
            driver: :ruby,
          },
        ],
        expire_after: 15.days,
        key: '_gcp_rails_demo_session'
      )
    end
  end
end
