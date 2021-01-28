# frozen_string_literal: true

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
    end
  end
end
