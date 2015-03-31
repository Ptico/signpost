# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'signpost/version'

Gem::Specification.new do |spec|
  spec.name          = 'signpost'
  spec.version       = Signpost::VERSION::String
  spec.authors       = ['Andrey Savchenko']
  spec.email         = ['andrey@aejis.eu']
  spec.summary       = %q{Yet another router for rack}
  spec.description   = %q{Standalone router for rack and nothing else}
  spec.homepage      = 'https://github.com/Ptico/signpost'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency('mustermann', '~> 0.4')
  spec.add_runtime_dependency('inflecto', '0.0.2')
end
