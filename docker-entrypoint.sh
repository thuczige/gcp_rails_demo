#!/bin/sh
set -ex

# create db if not exist
bundle exec rails db:create

# migration
bundle exec rails db:migrate

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
