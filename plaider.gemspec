# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plaider/version'

Gem::Specification.new do |spec|
  spec.name          = 'plaider'
  spec.version       = Plaider::VERSION
  spec.authors       = ['Gene Drabkin']
  spec.email         = ['gene.drabkin@gmail.com']
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.description   = %q{Wraps Plaid API in a simple client}
  spec.summary       = %q{Ruby client for Plaid API}
  spec.homepage      = 'https://github.com/cloocher/plaider'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.6'
end
