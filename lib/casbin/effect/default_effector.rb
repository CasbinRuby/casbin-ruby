# frozen_string_literal: true

require 'casbin/effect/effector'
require 'casbin/effect/allow_override_effector'
require 'casbin/effect/deny_override_effector'
require 'casbin/effect/allow_and_deny_effector'
require 'casbin/effect/priority_effector'

module Casbin
  module Effect
    # default effector for Casbin.
    class DefaultEffector < Effect::Effector
      # creates an effector based on the current policy effect expression
      def self.get_effector(expr)
        case expr
        when 'some(where (p_eft == allow))'
          Effect::AllowOverrideEffector.new
        when '!some(where (p_eft == deny))'
          Effect::DenyOverrideEffector.new
        when 'some(where (p_eft == allow)) && !some(where (p_eft == deny))'
          Effect::AllowAndDenyEffector.new
        when 'priority(p_eft) || deny'
          Effect::PriorityEffector.new
        else
          raise 'unsupported effect'
        end
      end

      def self.effect_to_bool(effect)
        return true if effect == ALLOW
        return false if effect == DENY

        raise "effect can't be converted to boolean"
      end
    end
  end
end
