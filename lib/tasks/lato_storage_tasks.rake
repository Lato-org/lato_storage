namespace :lato_storage do
  namespace :install do
    desc 'No-op, kept for compatibility. Only lato_storage:install:migrations is required'
    # Usage: rails lato_storage:install:application
    task :application do
      # Nothing to install on the host application.
    end
  end
end
