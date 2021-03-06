# frozen_string_literal: true

module Casbin
  require 'casbin-ruby/version'
  require 'casbin-ruby/enforcer'
  require 'casbin-ruby/synced_enforcer'
  require 'casbin-ruby/config'

  module Persist
    require 'casbin-ruby/persist/adapter'
  end
end
