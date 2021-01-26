# frozen_string_literal: true

module Casbin
  module Model
    class Policy
      # adds a policy rule to the model.
      def add_policy(sec, ptype, rule)
        # stub method
        puts "call add_policy with sec = #{sec} ptype = #{ptype} rule = #{rule}"
      end

      # adds an authorization rule to the current named policy.
      # If the rule already exists, the function returns false and the rule will not be added.
      # Otherwise the function returns true by adding the new rule.
      def add_named_policy(ptype, *params)
        # stub method
        puts "call add_named_policy with ptype = #{ptype} params = #{params}"
      end

      # gets all the authorization rules in the policy.
      def get_policy
        # stub method
        puts 'call get_policy'
      end

      # determines whether a model has the specified policy rule.
      def has_policy(sec, ptype, rule)
        # stub method
        puts "call has_policy sec = #{sec} ptype = #{ptype} rule = #{rule}"
      end

      # removes a policy rule from the model.
      def remove_policy(sec, ptype, rule)
        # stub method
        puts "call remove_policy sec = #{sec} ptype = #{ptype} rule = #{rule}"
      end

      # removes policy rules based on field filters from the model.
      def remove_filtered_policy(sec, ptype, field_index, *field_values)
        # stub method
        puts "call remove_filtered_policy sec = #{sec} ptype = #{ptype} field_index = #{field_index} field_values = #{field_values}"
      end
    end
  end
end
