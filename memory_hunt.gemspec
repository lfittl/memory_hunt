$:.push File.expand_path("../lib", __FILE__)
require 'memory_hunt/version'

Gem::Specification.new do |s|
  s.name        = 'memory_hunt'
  s.version     = MemoryHunt::VERSION

  s.summary     = 'Rack middleware for finding memory leaks'
  s.description = 'Middleware that finds left over objects after a request'
  s.author      = 'Lukas Fittl'
  s.email       = 'lukas@fittl.com'
  s.license     = 'BSD-2-Clause'
  s.homepage    = 'http://github.com/lfittl/memory_hunt'

  s.files = %w[
    LICENSE
    Rakefile
    lib/memory_hunt.rb
    lib/memory_hunt/middleware.rb
    lib/memory_hunt/version.rb
  ]

  s.add_development_dependency 'rspec', '~> 3.0'

  s.add_runtime_dependency "json", '~> 1.8'
  s.add_runtime_dependency "objspace_helpers"
end
