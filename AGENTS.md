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
- Run cleanup from the admin panel.
- Enable dashboard performance optimization for large datasets.

## Documentation

- User-facing documentation lives in `test/dummy/app/views/application/documentation.html.erb`.
- Keep that file updated whenever install steps, permissions, configuration, cleanup behavior, or usage changes.
- Documentation should explain what the gem does, how to install it, and how to use it.
- Avoid internal implementation details such as controller internals, route lists, job internals, private models, or database mechanics unless required for usage.

## Local setup

- Ruby via `rbenv`.
- Install gems: `bundle`.
- Migrate dummy DB: `rails db:migrate`.
- Seed dummy DB: `rails db:seed`.
- Start dev stack: `foreman start -f Procfile.dev`.

## Main commands

- Run tests: `bin/rails test`.
- Publish gem: `ruby ./bin/publish.rb`.

## Agent notes

- Keep Ruby strings double quoted.
- Keep cleanup documentation user-focused and warn about production data retention.
- Do not touch `.DS_Store` files if present.
