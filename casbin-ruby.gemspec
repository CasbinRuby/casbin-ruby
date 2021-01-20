# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "casbin/version"

Gem::Specification.new do |s|
  s.name        = "whenever"
  s.version     = Casbin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Igor Kutyavin"]
  s.email       = ["konayre@evrone.com"]
  s.homepage    = "https://github.com/evrone/casbin-ruby"
  s.licenses    = ["Apache License 2.0"]
  s.description = "An authorization library that supports access control models like ACL, RBAC, ABAC in Ruby"
end
