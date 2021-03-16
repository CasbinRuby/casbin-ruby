# frozen_string_literal: true

require 'keisan'

module Casbin
  module Util
    class Evaluator
      class NamesConflictError < RuntimeError; end

      class << self
        # evaluate an expression, using the operators, functions and names previously setup.
        def eval(expr, funcs = {}, params = {})
          validate_names funcs, params
          Keisan::Calculator.new.evaluate expr, funcs.merge(params)
        end

        def validate_names(funcs = {}, params = {})
          conflicted_names = funcs.keys & params.keys
          return if conflicted_names.empty?

          raise NamesConflictError, "You can't use function names as parameter names: " \
                                    "#{conflicted_names.map { |name| "`#{name}`" }.join ', '}"
        end
      end
    end
  end
end
