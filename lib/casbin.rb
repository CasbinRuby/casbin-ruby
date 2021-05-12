# frozen_string_literal: true

module Casbin
  require 'casbin/version'
  require 'casbin/enforcer'
  require 'casbin/synced_enforcer'

  module Persist
    require 'casbin/persist/adapter'
  end
end
