# frozen_string_literal: true

module Casbin
  module Model
    class Policy
      attr_reader :model

      def initialize
        @model = {}
      end

      # adds a policy rule to the model.
      def add_policy(sec, ptype, rule)
        return false if has_policy(sec, ptype, rule)

        model[sec][ptype].policy << rule
      end

      # gets all rules in a policy.
      def get_policy(sec, ptype)
        model[sec][ptype].policy
      end

      # determines whether a model has the specified policy rule.
      def has_policy(sec, ptype, rule)
        return false unless model.key?(sec)
        return false unless model[sec].include?(ptype)

        model[sec][ptype].policy.include?(rule)
      end

      # removes a policy rule from the model.
      def remove_policy(sec, ptype, rule)
        return false unless model.key?(sec)
        return false unless model[sec].include?(ptype)
        return false unless has_policy(sec, ptype, rule)

        model[sec][ptype].policy.delete(rule)
      end

      # removes policy rules based on field filters from the model.
      def remove_filtered_policy(sec, ptype, field_index, *field_values)
        return false unless model.key?(sec)
        return false unless model[sec].include?(ptype)

        state = { tmp: [], res: false }
        model[sec][ptype].policy.each do |rule|
          state = filtered_rule(state, rule, field_values, field_index)
        end

        model[sec][ptype].policy = state[:tmp]
        state[:res]
      end

      private

      def filtered_rule(state, rule, field_values, field_index)
        matched = true

        field_values.each_with_index do |field_value, index|
          next matched = false if field_value != '' && field_value != rule[field_index + index]

          if matched
            state[:res] = true
          else
            state[:tmp] << rule
          end
        end

        state
      end
    end
  end
end
