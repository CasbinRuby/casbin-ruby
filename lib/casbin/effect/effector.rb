# frozen_string_literal: true

module Casbin
  module Effect
    # Effector is the interface for Casbin effectors.
    class Effector
      ALLOW = 0
      INDETERMINATE = 1
      DENY = 2

      # merges all matching results collected by the enforcer into a single decision.
      def merge_effects(expr, effects, results); end
    end
  end
end
