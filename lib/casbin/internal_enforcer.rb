# frozen_string_literal: true

require 'casbin/core_enforcer'

module Casbin
  # InternalEnforcer = CoreEnforcer + Internal API.
  class InternalEnforcer < CoreEnforcer
    protected

    # adds a rule to the current policy.
    def add_policy(sec, ptype, rule)
      return false unless model.add_policy(sec, ptype, rule)

      make_persistent :add_policy, sec, ptype, rule
    end

    # adds rules to the current policy.
    def add_policies(sec, ptype, rules)
      return false unless model.add_policies(sec, ptype, rules)

      make_persistent :add_policies, sec, ptype, rules
    end

    # updates a rule from the current policy.
    def update_policy(sec, ptype, old_rule, new_rule)
      return false unless model.update_policy(sec, ptype, old_rule, new_rule)

      make_persistent :update_policy, sec, ptype, old_rule, new_rule
    end

    # updates rules from the current policy.
    def update_policies(sec, ptype, old_rules, new_rules)
      return false unless model.update_policies(sec, ptype, old_rules, new_rules)

      make_persistent :update_policies, sec, ptype, old_rules, new_rules
    end

    # removes a rule from the current policy.
    def remove_policy(sec, ptype, rule)
      return false unless model.remove_policy(sec, ptype, rule)

      make_persistent :remove_policy, sec, ptype, rule
    end

    # removes policy rules from the model.
    def remove_policies(sec, ptype, rules)
      return false unless model.remove_policies(sec, ptype, rules)

      make_persistent :remove_policies, sec, ptype, rules
    end

    # removes rules based on field filters from the current policy.
    def remove_filtered_policy(sec, ptype, field_index, *field_values)
      return false unless model.remove_filtered_policy(sec, ptype, field_index, *field_values)

      make_persistent :remove_filtered_policy, sec, ptype, field_index, *field_values
    end

    private

    def make_persistent(meth, *args)
      if adapter && auto_save
        # we can add the `add_policies`, `update_policy`, `update_policies`, `remove_policies` methods
        # to the base Adapter class and remove `respond_to?`
        return false unless adapter.respond_to?(meth) && adapter.public_send(meth, *args)

        watcher&.update
      end

      true
    end
  end
end
