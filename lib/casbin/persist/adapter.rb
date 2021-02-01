# frozen_string_literal: true

module Casbin
  module Persist
    # the interface for Casbin adapters.
    class Adapter
      # loads all policy rules from the storage.
      def load_policy(_model); end

      # saves all policy rules to the storage.
      def save_policy(_model); end

      # adds a policy rule to the storage.
      def add_policy(_sec, _ptype, _rule); end

      # removes a policy rule from the storage.
      def remove_policy(_sec, _ptype, _rule); end

      # removes policy rules that match the filter from the storage.
      # This is part of the Auto-Save feature.
      def remove_filtered_policy(_sec, _ptype, _field_index, *_field_values); end

      protected

      # loads a text line as a policy rule to model.
      def load_policy_line(line, model)
        return if line == '' || line[0] == '#'

        tokens = line.split(', ')
        key = tokens[0]
        sec = key[0]
        return unless model.model.key?(sec)
        return unless model.model[sec].key?(key)

        model.model[sec][key].policy << tokens[1..tokens.size]
      end
    end
  end
end
