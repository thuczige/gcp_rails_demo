source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

gem 'mysql2', '~> 0.5.6'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

gem 'hiredis', '~> 0.6.3'
gem 'redis', '~> 4.8', '>= 4.8.1', require: ['redis', 'redis/connection/hiredis']
gem 'redis-rails', '~> 5.0', '>= 5.0.2'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Accessing Google Cloud Storage for importing data
gem 'google-cloud-storage'

# To query Google Cloud IAM policy
gem 'google-cloud-resource_manager'

gem 'devise', '~> 4.9', '>= 4.9.3'

gem 'devise-bootstrap-views', '~> 1.0'

# Application ENV
gem 'figaro'
# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
# Metagem that includes google stackdriver logging
# + extra functionalities
gem 'stackdriver'
gem 'zgcp_toolkit'

# Using Google Cloud Task
gem 'google-cloud-tasks-v2'
gem 'rubocop', '~> 1.61'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'database_cleaner', '~> 2.0', '>= 2.0.2'
  gem 'rspec-rails', '~> 6.0', '>= 6.0.3'
  gem 'shoulda-matchers', '~> 5.3'
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'sqlite3', '~> 1.3', '>= 1.3.11'
end
