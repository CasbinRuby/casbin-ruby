# frozen_string_literal: true

module Casbin
  module Effect
    # Effector is the interface for Casbin effectors.
    class Effector
      ALLOW = 0
      INDETERMINATE = 1
      DENY = 2

      # returns a intermediate effect based on the matched effects of the enforcer
      def intermediate_effect(_effects); end

      # returns the final effect based on the matched effects of the enforcer
      def final_effect(_effects); end
    end
  end
end
