# frozen_string_literal: true

require 'casbin/persist/adapter'

module Casbin
  module Persist
    # BatchAdapter is the interface for Casbin adapters with multiple add and remove policy functions.
    class BatchAdapter < Persist::Adapter
      # AddPolicies adds policy rules to the storage.
      def add_policies(_sec, _ptype, _rules); end

      # LRemovePolicies removes policy rules from the storage.
      def remove_policies(_sec, _ptype, _rules); end
    end
  end
end
