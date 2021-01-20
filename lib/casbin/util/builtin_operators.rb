module Casbin
  module Util
    class BuiltinOperators
      class << self
        # The wrapper for key_match.
        def key_match_func(*args)
          # stub method
          puts "call key_match_func with args = #{args}"
        end

        def key_match2_func(*args)
          # stub method
          puts "call key_match2_func with args = #{args}"
        end

        def key_match3_func(*args)
          # stub method
          puts "call key_match3_func with args = #{args}"
        end

        # the wrapper for RegexMatch.
        def regex_match_func(*args)
          # stub method
          puts "call regex_match_func with args = #{args}"
        end

        # the wrapper for globMatch.
        def glob_match_func(*args)
          # stub method
          puts "call glob_match_func with args = #{args}"
        end

        # the wrapper for IPMatch.
        def ip_match_func(*args)
          # stub method
          puts "call ip_match_func with args = #{args}"
        end
      end
    end
  end
end
