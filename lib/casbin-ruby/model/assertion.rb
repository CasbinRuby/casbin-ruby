# frozen_string_literal: true

require 'casbin-ruby/logger'

module Casbin
  module Model
    class Assertion
      attr_accessor :key, :value, :tokens, :policy, :rm

      def initialize(hash = {})
        @key = hash[:key].to_s
        @value = hash[:value].to_s
        @tokens = [*hash[:tokens]]
        @policy = [*hash[:policy]]
      end

      def build_role_links(rm)
        @rm = rm
        count = value.count('_')
        policy.each do |rule|
          raise 'the number of "_" in role definition should be at least 2' if count < 2
          raise 'grouping policy elements do not meet role definition' if rule.size < count

          rm.add_link(*rule)
          Logger.info("Role links for: #{key}")
          rm.print_roles
        end
      end
    end
  end
end
