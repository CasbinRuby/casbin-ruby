# frozen_string_literal: true

require 'casbin/effect/effector'

module Casbin
  module Effect
    # default effector for Casbin.
    class DefaultEffector < Casbin::Effect::Effector
      # merges all matching results collected by the enforcer into a single decision.
      def merge_effects(expr, effects, _results)
        effects = Array(effects)
        result = false

        case expr
        when 'some(where (p_eft == allow))'
          result = true if effects.include?(ALLOW)
        when '!some(where (p_eft == deny))'
          result = true
          result = false if effects.include?(DENY)
        when 'some(where (p_eft == allow)) && !some(where (p_eft == deny))'
          result = false if effects.include?(DENY)
          result = true if effects.include?(ALLOW)
        when 'priority(p_eft) || deny'
          effects.each do |eft|
            next unless eft != INDETERMINATE

            result = eft == ALLOW
          end
        else
          raise 'unsupported effect'
        end

        result
      end
    end
  end
end
