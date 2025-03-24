require_relative "lib/queries/version"

Gem::Specification.new do |spec|
  spec.name        = "queries"
  spec.version     = Queries::VERSION
  spec.authors     = [ "Alef Ojeda de Oliveira" ]
  spec.email       = [ "nemubatubag@gmail.com" ]
  spec.homepage    = "https://github.com/nemuba/queries"
  spec.summary     = "Queries is a Ruby on Rails engine that provides a simple and efficient way to manage and execute database queries."
  spec.description = "This gem is designed to simplify the process of creating, managing, and executing database queries in Ruby on Rails applications."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nemuba/queries"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.1"
end
