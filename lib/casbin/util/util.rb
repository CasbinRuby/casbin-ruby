# frozen_string_literal: true

module Casbin
  module Util
    class Util
      # removes the comments starting with # in the text.
      def remove_comments(s)
        # stub method
        puts "call remove_comments with s = #{s}"
      end

      # escapes the dots in the assertion, because the expression evaluation doesn't support such variable names.
      def escape_assertion(s)
        # stub method
        puts "call escape_assertion with s = #{s}"
      end

      # gets a printable string for a string array.
      def array_remove_duplicates(s)
        # stub method
        puts "call array_remove_duplicates with s = #{s}"
      end

      # removes any duplicated elements in a string array.
      def array_to_string(s)
        # stub method
        puts "call array_to_string with s = #{s}"
      end

      # gets a printable string for variable number of parameters.
      def params_to_string(*s)
        # stub method
        puts "call params_to_string with s = #{s}"
      end

      # determine whether matcher contains function eval
      def has_eval(s)
        # stub method
        puts "call has_eval with s = #{s}"
      end

      # replace all occurrences of function eval with rules
      def replace_eval(expr, rules)
        # stub method
        puts "call replace_eval with expr = #{expr} rules = #{rules}"
      end

      # returns the parameters of function eval
      def get_eval_value(s)
        # stub method
        puts "call get_eval_value with s = #{s}"
      end
    end
  end
end
