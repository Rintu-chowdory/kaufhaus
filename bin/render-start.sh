#!/usr/bin/env bash
# Start command for Render.
#
# The app keeps its tables in the `kaufhaus` schema of a shared Postgres instance, so the
# schema has to exist before migrations run. Creating it is idempotent.
set -o errexit

bundle exec rails runner 'ActiveRecord::Base.connection.execute("CREATE SCHEMA IF NOT EXISTS kaufhaus")'

bundle exec rails db:migrate
bundle exec rails db:seed

exec bundle exec puma -C config/puma.rb
