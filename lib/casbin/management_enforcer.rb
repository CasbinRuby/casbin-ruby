# frozen_string_literal: true

require 'casbin/internal_enforcer'

module Casbin
  # ManagementEnforcer = InternalEnforcer + Management API.
  class ManagementEnforcer < Casbin::InternalEnforcer
    alias parent_add_policy add_policy
    alias parent_add_policies add_policies
    alias parent_update_policy update_policy
    alias parent_update_policies update_policies
    alias parent_remove_policy remove_policy
    alias parent_remove_policies remove_policies
    alias parent_remove_filtered_policy remove_filtered_policy

    # gets the list of subjects that show up in the current policy.
    def get_all_subjects
      get_all_named_subjects('p')
    end

    # gets the list of subjects that show up in the current named policy.
    def get_all_named_subjects(ptype)
      model.get_values_for_field_in_policy('p', ptype, 0)
    end

    # gets the list of objects that show up in the current policy.
    def get_all_objects
      get_all_named_objects('p')
    end

    # gets the list of objects that show up in the current named policy.
    def get_all_named_objects(ptype)
      model.get_values_for_field_in_policy('p', ptype, 1)
    end

    # gets the list of actions that show up in the current policy.
    def get_all_actions
      get_all_named_actions('p')
    end

    # gets the list of actions that show up in the current named policy.
    def get_all_named_actions(ptype)
      model.get_values_for_field_in_policy('p', ptype, 2)
    end

    # gets the list of roles that show up in the current named policy.
    def get_all_roles
      get_all_named_roles('g')
    end

    def get_all_named_roles(ptype)
      model.get_values_for_field_in_policy('g', ptype, 1)
    end

    # gets all the authorization rules in the policy.
    def get_policy
      get_named_policy('p')
    end

    # gets all the authorization rules in the policy, field filters can be specified.
    def get_filtered_policy(field_index, *field_values)
      get_filtered_named_policy('p', field_index, *field_values)
    end

    # gets all the authorization rules in the named policy.
    def get_named_policy(ptype)
      model.get_policy('p', ptype)
    end

    # gets all the authorization rules in the named policy, field filters can be specified.
    def get_filtered_named_policy(ptype, field_index, *field_values)
      model.get_filtered_policy('p', ptype, field_index, *field_values)
    end

    # gets all the role inheritance rules in the policy.
    def get_grouping_policy
      get_named_grouping_policy('g')
    end

    # gets all the role inheritance rules in the policy, field filters can be specified.
    def get_filtered_grouping_policy(field_index, *field_values)
      get_filtered_named_grouping_policy('g', field_index, *field_values)
    end

    # gets all the role inheritance rules in the policy.
    def get_named_grouping_policy(ptype)
      model.get_policy('g', ptype)
    end

    # gets all the role inheritance rules in the policy, field filters can be specified.
    def get_filtered_named_grouping_policy(ptype, field_index, *field_values)
      model.get_filtered_policy('g', ptype, field_index, *field_values)
    end

    # determines whether an authorization rule exists.
    def has_policy(*params)
      has_named_policy('p', *params)
    end

    # determines whether a named authorization rule exists.
    def has_named_policy(ptype, *params)
      if params.size == 1 && params[0].is_a?(Array)
        model.has_policy('p', ptype, params[0])
      else
        model.has_policy('p', ptype, [params])
      end
    end

    # adds an authorization rule to the current policy.
    #
    # If the rule already exists, the function returns false and the rule will not be added.
    # Otherwise the function returns true by adding the new rule.
    def add_policy(*params)
      add_named_policy('p', *params)
    end

    # adds authorization rules to the current policy.
    #
    # If the rule already exists, the function returns false for the corresponding rule and the rule will not be added.
    # Otherwise the function returns true for the corresponding rule by adding the new rule.
    def add_policies(rules)
      add_named_policies('p', rules)
    end

    # adds an authorization rule to the current named policy.
    #
    # If the rule already exists, the function returns false and the rule will not be added.
    # Otherwise the function returns true by adding the new rule.
    def add_named_policy(ptype, *params)
      if params.size == 1 && params[0].is_a?(Array)
        parent_add_policy('p', ptype, params[0])
      else
        parent_add_policy('p', ptype, [params])
      end
    end

    # adds authorization rules to the current named policy.
    #
    # If the rule already exists, the function returns false for the corresponding rule and the rule will not be added.
    # Otherwise the function returns true for the corresponding by adding the new rule.
    def add_named_policies(ptype, rules)
      parent_add_policies('p', ptype, rules)
    end

    # updates an authorization rule from the current policy.
    def update_policy(old_rule, new_rule)
      update_named_policy('p', old_rule, new_rule)
    end

    # updates authorization rules from the current policy.
    def update_policies(old_rules, new_rules)
      update_named_policies('p', old_rules, new_rules)
    end

    # updates an authorization rule from the current named policy.
    def update_named_policy(ptype, old_rule, new_rule)
      parent_update_policy('p', ptype, old_rule, new_rule)
    end

    # updates authorization rules from the current named policy.
    def update_named_policies(ptype, old_rules, new_rules)
      parent_update_policies('p', ptype, old_rules, new_rules)
    end

    # removes an authorization rule from the current policy.
    def remove_policy(*params)
      remove_named_policy('p', *params)
    end

    # removes authorization rules from the current policy.
    def remove_policies(rules)
      remove_named_policies('p', rules)
    end

    # removes an authorization rule from the current policy, field filters can be specified.
    def remove_filtered_policy(field_index, *field_values)
      remove_filtered_named_policy('p', field_index, *field_values)
    end

    # removes an authorization rule from the current named policy.
    def remove_named_policy(ptype, *params)
      if params.size == 1 && params[0].is_a?(Array)
        parent_remove_policy('p', ptype, params[0])
      else
        parent_remove_policy('p', ptype, [params])
      end
    end

    # removes authorization rules from the current named policy.
    def remove_named_policies(ptype, rules)
      parent_remove_policies('p', ptype, rules)
    end

    # removes an authorization rule from the current named policy, field filters can be specified.
    def remove_filtered_named_policy(ptype, field_index, *field_values)
      parent_remove_filtered_policy('p', ptype, field_index, *field_values)
    end

    # determines whether a role inheritance rule exists.
    def has_grouping_policy
      has_named_grouping_policy('g', *params)
    end

    # determines whether a named role inheritance rule exists.
    def has_named_grouping_policy(ptype, *params)
      if params.size == 1 && params[0].is_a?(Array)
        model.has_policy('g', ptype, params[0])
      else
        model.has_policy('g', ptype, [params])
      end
    end

    # adds a role inheritance rule to the current policy.
    #
    # If the rule already exists, the function returns false and the rule will not be added.
    # Otherwise the function returns true by adding the new rule.
    def add_grouping_policy(*params)
      add_named_grouping_policy('g', *params)
    end

    # adds role inheritance rulea to the current policy.
    #
    # If the rule already exists, the function returns false for the corresponding policy rule and the rule will not be
    # added.
    # Otherwise the function returns true for the corresponding policy rule by adding the new rule.
    def add_grouping_policies(rules)
      add_named_grouping_policies('g', rules)
    end

    # adds a named role inheritance rule to the current policy.
    #
    # If the rule already exists, the function returns false and the rule will not be added.
    # Otherwise the function returns true by adding the new rule.
    def add_named_grouping_policy(ptype, *params)
      rule_added = if params.size == 1 && params[0].is_a?(Array)
                     parent_add_policy('g', ptype, params[0])
                   else
                     parent_add_policy('g', ptype, [params])
                   end

      auto_build_role_links ? build_role_links : rule_added
    end

    # adds named role inheritance rules to the current policy.
    #
    # If the rule already exists, the function returns false for the corresponding policy rule and the rule will not be
    # added.
    # Otherwise the function returns true for the corresponding policy rule by adding the new rule.
    def add_named_grouping_policies(ptype, rules)
      rules_added = parent_add_policies('g', ptype, rules)
      auto_build_role_links ? build_role_links : rules_added
    end

    # removes a role inheritance rule from the current policy.
    def remove_grouping_policy(*params)
      remove_named_grouping_policy('g', *params)
    end

    # removes role inheritance rulea from the current policy.
    def remove_grouping_policies(rules)
      remove_named_grouping_policies('g', rules)
    end

    # removes a role inheritance rule from the current policy, field filters can be specified.
    def remove_filtered_grouping_policy(field_index, *field_values)
      remove_filtered_named_grouping_policy('g', field_index, *field_values)
    end

    # removes a role inheritance rule from the current named policy.
    def remove_named_grouping_policy(ptype, *params)
      rule_added = if params.size == 1 && params[0].is_a?(Array)
                     parent_remove_policy('g', ptype, params[0])
                   else
                     parent_remove_policy('g', ptype, [params])
                   end

      auto_build_role_links ? build_role_links : rule_added
    end

    # removes role inheritance rules from the current named policy.
    def remove_named_grouping_policies(ptype, rules)
      rules_removed = parent_remove_policies('g', ptype, rules)
      auto_build_role_links ? build_role_links : rules_removed
    end

    # removes a role inheritance rule from the current named policy, field filters can be specified.
    def remove_filtered_named_grouping_policy(ptype, field_index, *field_values)
      rule_removed = parent_remove_filtered_policy('g', ptype, field_index, *field_values)
      auto_build_role_links ? build_role_links : rule_removed
    end

    # adds a customized function.
    def add_function(name, func)
      fm.add_function(name, func)
    end
  end
end
