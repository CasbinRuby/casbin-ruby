# frozen_string_literal: true

module Casbin
  module Model
    class FunctionMap
      alias get_functions fm

      def initialize
        @fm = {}
      end

      def add_function(name, func)
        fm[name] = func
      end

      def self.load_function_map
        @fm = FunctionMap.new
        fm.add_function('keyMatch', ->(*args) { Casbin::Util::BuiltinOperators.key_match_func(args) })
        fm.add_function('keyMatch2', ->(*args) { Casbin::Util::BuiltinOperators.key_match2_func(args) })
        fm.add_function('regexMatch', ->(*args) { Casbin::Util::BuiltinOperators.regex_match_func(args) })
        fm.add_function('ipMatch', ->(*args) { Casbin::Util::BuiltinOperators.ip_match_func(args) })
        fm.add_function('globMatch', ->(*args) { Casbin::Util::BuiltinOperators.glob_match_func(args) })
      end

      private

      attr_reader :fm
    end
  end
end
