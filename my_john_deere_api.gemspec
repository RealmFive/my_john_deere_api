require_relative './lib/my_john_deere_api/version'

Gem::Specification.new do |s|
  s.name        = 'my_john_deere_api'
  s.version     = MyJohnDeereApi::VERSION
  s.summary     = "Interact with John Deere's Developer API"
  s.authors     = ["Jaime Bellmyer", 'Justin Collier']
  s.email       = 'online@bellmyer.com'
  s.homepage    = 'https://github.com/Intellifarm/my_john_deere_api'
  s.license       = 'MIT'

  s.files       = Dir["{lib,test}/**/*", "Rakefile", "README.md"]

  s.add_development_dependency 'vcr', '~> 5.0'
  s.add_development_dependency 'dotenv', '~> 2.7.5'
  s.add_development_dependency 'webmock', '~> 3.7.6'

  s.add_runtime_dependency 'oauth', '~> 0.5.4'
  s.add_runtime_dependency 'json', '~> 2.1', '>= 2.1.0'

  s.description = <<-TURTLES
== My John Deere API

This gem interacts with the My John Deere API.

WARNING: this is a work in progress. We believe in publish early,
publish often. Perfection is the enemy of done. Insert third
cliché here ;)
  TURTLES
end