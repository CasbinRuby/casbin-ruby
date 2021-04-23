# frozen_string_literal: true

require 'logger'

module Casbin
  module Model
    class Policy
      attr_reader :model, :logger

      def initialize(logger: Logger.new($stdout))
        @model = {}
        @logger = logger
      end

      # initializes the roles in RBAC.
      def build_role_links(rm_map)
        return unless model.key? 'g'

        model['g'].each do |ptype, ast|
          rm = rm_map[ptype]
          ast.build_role_links(rm)
        end
      end

      # Log using info
      def print_policy
        logger.info 'Policy:'

        %w[p g].each do |sec|
          next unless model.key? sec

          model[sec].each do |key, ast|
            logger.info "#{key} : #{ast.value} : #{ast.policy}"
          end
        end
      end

      # clears all current policy.
      def clear_policy
        %w[p g].each do |sec|
          next unless model.key? sec

          model[sec].each do |key, _ast|
            model[sec][key].policy = []
          end
        end
      end

      # adds a policy rule to the model.
      def add_policy(sec, ptype, rule)
        return false if has_policy(sec, ptype, rule)

        model[sec][ptype].policy << rule

        true
      end

      # adds policy rules to the model.
      def add_policies(sec, ptype, rules)
        rules.each do |rule|
          return false if has_policy(sec, ptype, rule)
        end

        model[sec][ptype].policy += rules

        true
      end

      # update a policy rule from the model.
      def update_policy(sec, ptype, old_rule, new_rule)
        return false unless has_policy(sec, ptype, old_rule)

        remove_policy(sec, ptype, old_rule) && add_policy(sec, ptype, new_rule)
      end

      # update policy rules from the model.
      def update_policies(sec, ptype, old_rules, new_rules)
        old_rules.each do |rule|
          return false unless has_policy(sec, ptype, rule)
        end

        remove_policies(sec, ptype, old_rules) && add_policies(sec, ptype, new_rules)
      end

      # gets all rules in a policy.
      def get_policy(sec, ptype)
        model[sec][ptype].policy
      end

      # determines whether a model has the specified policy rule.
      def has_policy(sec, ptype, rule)
        model.key?(sec) && model[sec].key?(ptype) && model[sec][ptype].policy.include?(rule)
      end

      # removes a policy rule from the model.
      def remove_policy(sec, ptype, rule)
        return false unless has_policy(sec, ptype, rule)

        model[sec][ptype].policy.delete(rule)

        true
      end

      # removes policy rules from the model.
      def remove_policies(sec, ptype, rules)
        rules.each do |rule|
          return false unless has_policy(sec, ptype, rule)
        end

        model[sec][ptype].policy.reject! { |rule| rules.include? rule }

        true
      end

      # removes policy rules based on field filters from the model.
      def remove_filtered_policy(sec, ptype, field_index, *field_values)
        return false unless model.key?(sec) && model[sec].include?(ptype)

        state = { tmp: [], res: false }
        model[sec][ptype].policy.each do |rule|
          state = filtered_rule(state, rule, field_values, field_index)
        end

        model[sec][ptype].policy = state[:tmp]
        state[:res]
      end

      # gets all values for a field for all rules in a policy, duplicated values are removed.
      def get_values_for_field_in_policy(sec, ptype, field_index)
        values = []
        return values unless model.keys.include?(sec)
        return values unless model[sec].include?(ptype)

        model[sec][ptype].policy.each do |rule|
          value = rule[field_index]
          values << value if values.include?(value)
        end

        values
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
