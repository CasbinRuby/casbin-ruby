# frozen_string_literal: true

module Casbin
  module Util
    EVAL_REG = /\beval\(([^),]*)\)/.freeze

    class << self
      # removes the comments starting with # in the text.
      def remove_comments(string)
        string.split('#').first.strip
      end

      # Escapes the dots in the assertion, because the expression evaluation doesn't support such variable names.
      # Also it replaces attributes with hash syntax (`r.obj.Owner` -> `r_obj['Owner']`,
      # `r.obj.Owner.Position` -> `r_obj['Owner']['Position']`), because Keisan functions work
      # in both regular `f(x)` and postfix `x.f()` notation, where for example `a.f(b,c)` is translated internally
      # to `f(a,b,c)` - https://github.com/project-eutopia/keisan#specifying-functions
      # For now we replace attributes for the request elements like `r.sub`, `r.obj`, `r.act`
      # https://casbin.org/docs/en/abac#how-to-use-abac
      # We support Unicode in attributes for the compatibility with Golang - https://golang.org/ref/spec#Identifiers
      def escape_assertion(string)
        string.gsub /\br\.(\w+)((?:\.[[:alpha:]_][[:alnum:]_]*)+)/ do |_|
          param = Regexp.last_match(1)
          attrs = Regexp.last_match(2)[1..].split('.').map do |attr|
            "['#{attr}']"
          end.join
          "r_#{param}#{attrs}"
        end.gsub('r.', 'r_').gsub('p.', 'p_')
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
        i = -1
        expr.gsub EVAL_REG do |_|
          i += 1
          if rules.is_a? Hash
            "(#{escape_assertion rules[Regexp.last_match 1]})"
          else
            "(#{escape_assertion rules[i]})"
          end
        end
      end

      # For now, it does not used.
      # Returns the parameters of function eval.
      def get_eval_value(string)
        string.scan(EVAL_REG).flatten
      end

      # joins a string and a slice into a new slice.
      def join_slice(a, *b)
        Array.new(a).concat b
      end

      # returns the elements in `a` that aren't in `b`.
      def set_subtract(a, b)
        a - b
      end
    end
  end
end
