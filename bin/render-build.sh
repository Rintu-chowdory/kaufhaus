#!/usr/bin/env bash
# Build step for Render (native Ruby runtime).
#
# This used to run db:migrate and db:seed too, which made the build depend on a reachable
# database: when the database went away the build failed after about 15 seconds with no
# useful message. Migrations belong to the start command, where a failure is visible in the
# app logs instead of being reported as a build error.
set -o errexit

bundle install
bundle exec rails assets:precompile
