pin "lato_storage/application", to: "lato_storage/application.js"
pin_all_from LatoStorage::Engine.root.join("app/assets/javascripts/lato_storage/controllers"), under: "controllers", to: "lato_storage/controllers"
