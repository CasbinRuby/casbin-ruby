# frozen_string_literal: true

module Casbin
  module Util
    class SimpleEval
      # Create the evaluator instance. Setup valid operators (+,-, etc)
      # functions (add, random, get_val, whatever) and names.
      def initialize(_expr, _functions = nil)
        # stub
        puts 'initialize SimpleEval'
      end

      # evaluate an expression, using the operators, functions and names previously setup.
      def eval(names = nil)
        # stub
        puts 'eval'
      end
    end
  end
end
