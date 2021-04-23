# frozen_string_literal: true

require 'casbin/persist/adapter'

module Casbin
  module Persist
    # FilteredAdapter is the interface for Casbin adapters supporting filtered policies.
    class FilteredAdapter < Persist::Adapter
      # IsFiltered returns true if the loaded policy has been filtered
      # Marks if the loaded policy is filtered or not
      def filtered?; end

      # Loads policy rules that match the filter from the storage.
      def load_filtered_policy(_model, _filter); end
    end
  end
end
