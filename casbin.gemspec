# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'casbin/version'

Gem::Specification.new do |s|
  s.name        = 'casbin'
  s.version     = Casbin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Igor Kutyavin']
  s.email       = ['konayre@evrone.com']
  s.homepage    = 'https://github.com/evrone/casbin-ruby'
  s.licenses    = ['Apache License 2.0']
  s.description = 'An authorization library that supports access control models like ACL, RBAC, ABAC in Ruby'
  s.summary     = 'Casbin in Ruby'
  s.required_ruby_version = '>= 2.5.0'

  s.add_dependency 'keisan', '~> 0.8.0'

  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'rubocop', '>= 1.8'
  s.add_development_dependency 'rubocop-rspec'
end
