# Kaufhaus

A small Rails storefront: a product catalogue, a session-backed cart and Devise accounts.
It started life as a scaffold called "rintu-shop" and is now named after what it is.

## Stack

- Ruby 3.3.8, Rails 8.1
- PostgreSQL in production, SQLite-free (the app expects a real `DATABASE_URL`)
- Propshaft + importmap, Turbo/Stimulus, Devise for auth
- Solid Cache, Solid Queue and Solid Cable (database-backed, no Redis)
- Puma behind Thruster when containerised (`Dockerfile` + `bin/docker-entrypoint`)

## Local development

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

The app runs at http://localhost:3000. `bin/rails db:seed` loads the demo catalogue.

## Deploying to Render

The service is a **web service** on the native Ruby runtime, region Frankfurt, free plan.

| Setting | Value |
| --- | --- |
| Build command | `./bin/render-build.sh` |
| Start command | `bundle exec rails db:migrate && bundle exec puma -C config/puma.rb` |
| Health check | `/up` |

Required environment variables:

| Variable | Why |
| --- | --- |
| `DATABASE_URL` | Postgres connection string. The app refuses to boot without it. |
| `RAILS_MASTER_KEY` | Unlocks `config/credentials.yml.enc` (secret key base, mailer keys). |
| `RAILS_ENV` | `production` |
| `WEB_CONCURRENCY` | Puma workers, keep at `1` on the free plan. |

### The database part that bites

Render's free Postgres instances **expire 30 days after creation**, and this app's first
database did exactly that. When the host disappears, `db:migrate` in the start command
fails, Puma never boots, and every request returns a 500 while the instance restart-loops.
Free accounts can only hold one active free database at a time.

So either keep the database outside Render (Supabase, Neon) or expect to recreate it
monthly and re-seed. Nothing in the app depends on Render specifically.

## Tests

```bash
bin/rails test
bin/rails test:system
```

CI runs RuboCop, Brakeman, bundler-audit and the test suites on every push.
