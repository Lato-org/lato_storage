require_relative "lib/lato_storage/version"

Gem::Specification.new do |spec|
  spec.name        = "lato_storage"
  spec.version     = LatoStorage::VERSION
  spec.authors     = ["Gregorio Galante"]
  spec.email       = ["me@gregoriogalante.com"]
  spec.homepage    = "https://github.com/Lato-org/lato_storage"
  spec.summary     = "Another engine for Lato projects"
  spec.description = "A Rails engine to manage application storage on Lato projects!"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Lato-org/lato_storage"
  # spec.metadata["changelog_uri"] = "Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.1"
  spec.add_dependency "lato"
end
