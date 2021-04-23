# frozen_string_literal: true

require 'casbin/effect/effector'

module Casbin
  module Effect
    class AllowOverrideEffector < Effect::Effector
      # returns a intermediate effect based on the matched effects of the enforcer
      def intermediate_effect(effects)
        return ALLOW if effects.include?(ALLOW)

        INDETERMINATE
      end

      # returns the final effect based on the matched effects of the enforcer
      def final_effect(effects)
        return ALLOW if effects.include?(ALLOW)

        DENY
      end
    end
  end
end
