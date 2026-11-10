# AGENTS

## Project overview

Lato is ecosystem of Rails engines for building admin panels with authentication, user management, Bootstrap UI, reusable components, operations, settings, storage, spaces, and CMS features.

`lato_storage` is extension gem for the base `lato` engine.

## Gem purpose

`lato_storage` adds Active Storage monitoring and cleanup tools to a Lato admin panel.

Admins can:

- View storage usage overview.
- Browse uploaded files and storage metadata.
- Identify unattached files.
- Run cleanup from the admin panel (job `Lato::ActiveStorageCleanerJob` lives in the `lato` gem; irreversible, with confirmation and concurrency lock).
- Enable dashboard performance optimization for large datasets.

## Documentation

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`.
- Keep that file updated whenever install steps, permissions, configuration, cleanup behavior, or usage changes.
- Documentation should explain what the gem does, how to install it, and how to use it.
- Avoid internal implementation details such as controller internals, private models, or database mechanics. Routes, the preload job, caching and cleaner rules are operational and must be documented.
- Keep `README.md` and the dummy documentation aligned.

## Behavior notes

- Access: `lato_storage_admin` flag on `Lato::User`; it gives visibility on files of all models/users/groups.
- Config: `optimize_performances` (estimates, cached dashboard data) and `blob_url_expires_in` (default 12 hours).
- `PreloadDashboardDataJob` needs a shared `Rails.cache`; it always returns a complete data hash (`computing`/`error` flags), never nil.
- Cleaner removes unattached blobs older than 12 hours via `purge_later` (needs Active Job worker).
- Install: only `rails lato_storage:install:migrations` is required (`install:application` is a no-op). Mount path convention: `/lato-storage`.
- Host menu entry must be added in the host `layouts/lato` navbar/sidebar partials.

## Local setup

- Ruby via `rbenv`.
- Install gems: `bundle`.
- Migrate dummy DB: `rails db:migrate`.
- Seed dummy DB: `rails db:seed`.
- Start dummy app: `rails server` (no `Procfile.dev` in this repo).

## Main commands

- Run tests: `bin/rails test`.
- Publish gem: `ruby ./bin/publish.rb`.

## Agent notes

- Keep Ruby strings double quoted.
- Keep cleanup documentation user-focused and warn about production data retention.
- Do not touch `.DS_Store` files if present.

## Security release baseline

- Rails 8.1.3.1 or newer in the 8.1 series is required.
- Run `ruby bin/publish.rb` from a named release branch after tests pass. It builds the exact version, commits changes, tags that commit, publishes to RubyGems, and pushes the branch and tag.
- Applications using Active Storage with vips require libvips 8.13 or newer.
