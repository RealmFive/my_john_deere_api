require_relative './lib/my_john_deere_api/version'

Gem::Specification.new do |s|
  s.name        = 'my_john_deere_api'
  s.version     = MyJohnDeereApi::VERSION
  s.summary     = "Interact with John Deere's Developer API"
  s.authors     = ["Jaime. Bellmyer"]
  s.email       = 'online@bellmyer.com'
  s.homepage    = 'https://github.com/Intellifarm/my_john_deere_api'
  s.license       = 'MIT'

  s.files       = ["{lib,test}/**/*", "Rakefile", "README.md"]

  s.description = <<-TURTLES
== My John Deere API

This gem interacts with the My John Deere API.

WARNING: this is a work in progress. We believe in publish early,
publish often. Perfection is the enemy of done. Insert third
cliché here ;)
  TURTLES
end