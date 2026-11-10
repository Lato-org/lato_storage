# Lato Storage
Manage application storage (ActiveStorage data) on Lato projects.

NOTE: This gem is using [Active Storage Dashboard](https://github.com/giovapanasiti/active_storage_dashboard) as reference for the interface and the functionality. The idea is to provide a similar interface inside Lato.

## Installation

Requires Rails 8.1.3.1 or newer in the 8.1 series, Lato 3.25.0 or newer and Active Storage installed on the host application (`rails active_storage:install`). Applications using variants with vips require libvips 8.13 or newer.
Add required dependencies to your application's Gemfile:

```ruby
# Use lato as application panel
gem "lato"
gem "lato_storage"
```

Install gem and run required tasks:

```bash
$ bundle
$ rails lato_storage:install:migrations
$ rails db:migrate
```

Mount lato storage routes on the **config/routes.rb** file:

```ruby
Rails.application.routes.draw do
  mount LatoStorage::Engine => "/lato-storage"

  # ....
end
```

Import Lato Storage Scss on **app/assets/stylesheets/application.scss** file:
```scss
@import 'lato_storage/application';

// ....
```

Import Lato Storage Js on **app/javascript/application.js** file:
```js
import "lato_storage/application";

// ....
```

Add a menu entry in the host application navbar or sidebar partials (`app/views/layouts/lato/_navbar-nav_content.html.erb` or `_sidebar-nav_content.html.erb`):

```erb
<% if @session.user&.lato_storage_admin %>
  <%= lato_sidebar_nav_item :lato_storage, lato_storage.root_path do %>
    <i class="bi bi-hdd me-2"></i> Storage
  <% end %>
<% end %>
```

(`rails lato_storage:install:application` is a no-op kept for compatibility: it is not required.)

## Permissions

Access requires a Lato session and the `lato_storage_admin` flag on `Lato::User` (added by `rails lato_storage:install:migrations`). Other users are redirected with an alert.

```ruby
Lato::User.find_by(email: "admin@example.com").update!(lato_storage_admin: true)
```

**The flag grants visibility on the files of every model, user and group** (including `lato_spaces` groups): filename, record reference and a download link. Give it only to super admins.

## Features and routes

Routes are relative to the mount path (`/lato-storage`):

- `GET /`: dashboard (blobs, attachments, variants, deletable blobs, total and average storage, content type distribution, 3 largest blobs).
- `GET /blobs`, `GET /attachments`, `GET /variant_records`: searchable, sortable, paginated lists.
- `POST /cleaner`: starts the cleanup (see below).

Links to files are signed, forced as download and expire after `blob_url_expires_in` (default 12 hours).

## Configuration

```ruby
LatoStorage.configure do |config|
  config.optimize_performances = true
  config.blob_url_expires_in = 12.hours
end
```

With `optimize_performances = true`:

- blobs, attachments and variants counts are estimates (`TABLE_ROWS` on MySQL, `reltuples` on PostgreSQL, exact `count` on other databases);
- total storage and content types are extrapolated from a sample of the last 5000 blobs;
- the "largest blobs" card is hidden and lists skip the total count;
- the dashboard data is cached for 12 hours and shows the "updated at" time.

With `false` (default) every dashboard visit runs the queries synchronously: exact values, but slow on large tables.

### PreloadDashboardDataJob

With optimization enabled, `LatoStorage::PreloadDashboardDataJob` computes and caches the dashboard data (data TTL 12 hours, lock TTL 30 minutes). Requirements and behavior:

- `Rails.cache` must be a store shared between web and worker processes (not `:null_store`, `:memory_store` or per-process `:file_store`), and a real Active Job queue adapter is needed for the background refresh.
- The first visit without cache computes the data synchronously. While a calculation is running the dashboard shows zeroed values with a "computing" notice; if it fails it shows an error notice.
- Pre-warm it with a recurring job, for example with Solid Queue (`config/recurring.yml`):

```yaml
production:
  lato_storage_preload:
    class: LatoStorage::PreloadDashboardDataJob
    args: [true]
    schedule: every 6 hours
```

## Cleanup

The "Free up space" button asks confirmation and starts `POST /cleaner`, which runs `Lato::ActiveStorageCleanerJob` (from `lato`) as a Lato operation.

- It calls `purge_later` on every blob **without attachments created more than 12 hours ago**: an Active Job worker is required and the deletion is **irreversible**.
- Blobs referenced only by id in custom columns or JSON are considered orphans too.
- Empty folders of a local disk service are removed.
- Only one cleanup per 10 minutes can be started (cache lock, same shared cache requirement as above).

Headless run: `Lato::Operation.generate("Lato::ActiveStorageCleanerJob", {}, user_id).start`.

## Security notes

Keep the Rails defaults for `config.active_storage.content_types_to_serve_as_binary` and `content_types_allowed_inline`: if HTML or SVG files uploaded by users were served inline, opening a link from the list would run them on the admin origin.

## Upgrading

```bash
bundle update lato_storage
rails lato_storage:install:migrations
rails db:migrate
```

Read [UPGRADING.md](UPGRADING.md) for the changes and extra steps required by each version.

## Development

Clone repository, install dependencies, run migrations and start:

```shell
$ git clone https://github.com/Lato-GAM/lato_storage
$ cd lato_storage
$ bundle
$ rails db:migrate
$ rails db:seed
$ rails server
```

The dummy app is mounted at `/lato-storage`. `rails db:seed` creates the development user `admin@mail.com` / `Password1!` (dummy only).

## Publish

```shell
$ ruby ./bin/publish.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

