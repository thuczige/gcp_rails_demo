#!/bin/sh
set -x

# create db if not exist
bundle exec rails db:create

# migration
bundle exec rails db:migrate

# Remove a potentially pre-existing server.pid for Rails.
if [ -f tmp/pids/server.pid ]; then
  rm -f tmp/pids/server.pid
fi

bundle exec rails s -p 8080 -b 0.0.0.0
