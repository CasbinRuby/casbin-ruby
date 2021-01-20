module Casbin
  # ManagementEnforcer = InternalEnforcer + Management API.
  class ManagementEnforcer < Casbin::InternalEnforcer
    # gets the list of subjects that show up in the current policy.
    def get_all_subjects
      # stub method
      puts "call get_all_subjects"
    end

    # gets the list of objects that show up in the current policy.
    def get_all_objects
      # stub method
      puts "call get_all_objects"
    end

    # gets the list of actions that show up in the current policy.
    def get_all_actions
      # stub method
      puts "call get_all_actions"
    end

    # gets the list of roles that show up in the current named policy.
    def get_all_roles
      # stub method
      puts "call get_all_roles"
    end

    # gets all the authorization rules in the policy, field filters can be specified.
    def get_filtered_policy(field_index, *field_values)
      # stub method
      puts "call get_filtered_policy with field_index = #{field_index} field_values = #{field_values}"
    end

    # determines whether an authorization rule exists.
    def has_policy(*params)
      # stub method
      puts "call has_policy with params = #{params}"
    end

    # gets all the role inheritance rules in the policy.
    def get_grouping_policy
      # stub method
      puts "call get_grouping_policy"
    end

    # gets all the role inheritance rules in the policy, field filters can be specified.
    def get_filtered_grouping_policy
      # stub method
      puts "call get_filtered_grouping_policy"
    end

    # determines whether a role inheritance rule exists.
    def has_grouping_policy
      # stub method
      puts "call has_grouping_policy"
    end

    # gets all the authorization rules in the policy.
    def get_policy
      # stub method
      puts "call get_policy"
    end

    # adds authorization rules to the current policy.
    #
    # If the rule already exists, the function returns false for the corresponding rule and the rule will not be added.
    # Otherwise the function returns true for the corresponding rule by adding the new rule.
    def add_policies(rules)
      # stub method
      puts "call add_named_policies rules = #{rules}"
    end

    # adds authorization rules to the current named policy.
    #
    # If the rule already exists, the function returns false for the corresponding rule and the rule will not be added.
    # Otherwise the function returns true for the corresponding by adding the new rule.
    def add_named_policies(ptype, rules)
      # stub method
      puts "call add_named_policies ptype = #{ptype} rules = #{rules}"
    end

    # removes authorization rules from the current policy.
    def remove_policies(rules)
      # stub method
      puts "call add_named_policies rules = #{rules}"
    end

    # removes authorization rules from the current named policy.
    def remove_named_policies(ptype, rules)
      # stub method
      puts "call remove_named_policies ptype = #{ptype} rules = #{rules}"
    end
  end
end
