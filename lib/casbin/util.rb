# frozen_string_literal: true

module Casbin
  module Util
    EVAL_REG = /\beval\(([^),]*)\)/.freeze

    class << self
      # removes the comments starting with # in the text.
      def remove_comments(string)
        string.split('#').first.strip
      end

      # escapes the dots in the assertion, because the expression evaluation doesn't support such variable names.
      def escape_assertion(string)
        string.gsub('r.', 'r_').gsub('p.', 'p_')
      end

      # removes any duplicated elements in a string array.
      def array_remove_duplicates(arr)
        arr.uniq
      end

      # gets a printable string for a string array.
      def array_to_string(arr)
        arr.join(', ')
      end

      # gets a printable string for variable number of parameters.
      def params_to_string(*params)
        params.join(', ')
      end

      # determine whether matcher contains function eval
      def has_eval(string)
        EVAL_REG.match?(string)
      end

      # replace all occurrences of function eval with rules
      def replace_eval(expr, rules)
        rules.each_index do |index|
          EVAL_REG.match(expr, index) { |math| expr = expr.gsub(math[0], "(#{math[1]})") }
        end

        expr
      end

      # returns the parameters of function eval
      def get_eval_value(string)
        string.scan(EVAL_REG).flatten
      end
    end
  end
end
