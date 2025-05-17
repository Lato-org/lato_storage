Lato.configure do |config|
  config.application_title = 'Lato example app'
  config.application_version = LatoStorage::VERSION

  config.session_root_path = :documentation_path
end

LatoStorage.configure do |config|
end
