# Lato Storage
Manage application storage (ActiveStorage data) on Lato projects.

🚨 THIS GEM IN UNDER DEVELOPMENT 🚨

NOTE: This gem is using [Active Storage Dashboard](https://github.com/giovapanasiti/active_storage_dashboard) as reference for the interface and the functionality. The idea is to provide a similar interface inside Lato.

## Installation
Add required dependencies to your application's Gemfile:

```ruby
# Use lato as application panel
gem "lato"
gem "lato_storage"
```

Install gem and run required tasks:

```bash
$ bundle
$ rails lato_storage:install:application
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

Import Lato Scss on **app/assets/stylesheets/application.scss** file:
```scss
@import 'lato_storage/application';

// ....
```

Import Lato Storage Js on **app/javascript/application.js** file:
```js
import "lato_storage/application";

// ....
```

## Development

Clone repository, install dependencies, run migrations and start:

```shell
$ git clone https://github.com/Lato-GAM/lato_storage
$ cd lato_storage
$ bundle
$ rails db:migrate
$ rails db:seed
$ foreman start -f Procfile.dev
```

## Publish

```shell
$ ruby ./bin/publish.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

