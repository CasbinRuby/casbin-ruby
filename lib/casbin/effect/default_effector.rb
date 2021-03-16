# frozen_string_literal: true

require 'casbin/effect/effector'

module Casbin
  module Effect
    # default effector for Casbin.
    class DefaultEffector < Casbin::Effect::Effector
      # merges all matching results collected by the enforcer into a single decision.
      def merge_effects(expr, effects, _results)
        effects = Array(effects)

        case expr
        when 'some(where (p_eft == allow))'
          effects.include? ALLOW
        when '!some(where (p_eft == deny))'
          !effects.include? DENY
        when 'some(where (p_eft == allow)) && !some(where (p_eft == deny))'
          !effects.include?(DENY) && effects.include?(ALLOW)
        when 'priority(p_eft) || deny'
          result = false
          effects.each do |eft|
            next if eft == INDETERMINATE

            result = eft == ALLOW
            break
          end

          result
        else
          raise 'unsupported effect'
        end
      end
    end
  end
end
