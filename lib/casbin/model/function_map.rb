# frozen_string_literal: true

module Casbin
  module Model
    class FunctionMap
      def initialize
        @fm = {}
      end

      attr_reader :fm
      alias get_functions fm

      def add_function(name, func)
        fm[name] = func
      end

      # It might be better to move this to initialize
      def self.load_function_map
        fm = FunctionMap.new
        fm.add_function('keyMatch', ->(*args) { Util::BuiltinOperators.key_match_func(*args) })
        fm.add_function('keyMatch2', ->(*args) { Util::BuiltinOperators.key_match2_func(*args) })
        fm.add_function('regexMatch', ->(*args) { Util::BuiltinOperators.regex_match_func(*args) })
        fm.add_function('ipMatch', ->(*args) { Util::BuiltinOperators.ip_match_func(*args) })
        fm.add_function('globMatch', ->(*args) { Util::BuiltinOperators.glob_match_func(*args) })

        fm
      end
    end
  end
end
