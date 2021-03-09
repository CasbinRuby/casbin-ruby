# frozen_string_literal: true

module Casbin
  module Util
    module BuiltinOperators
      KEY_MATCH2_PATTERN = %r{:[^/]+}.freeze
      KEY_MATCH3_PATTERN = %r{\{[^/]+\}}.freeze

      class << self
        # The wrapper for key_match.
        def key_match_func(*args)
          key_match(args[0], args[1])
        end

        def key_match2_func(*args)
          key_match2(args[0], args[1])
        end

        def key_match3_func(*args)
          key_match3(args[0], args[1])
        end

        # the wrapper for RegexMatch.
        def regex_match_func(*args)
          regex_match(args[0], args[1])
        end

        # the wrapper for globMatch.
        def glob_match_func(*args)
          glob_match(args[0], args[1])
        end

        # the wrapper for IPMatch.
        def ip_match_func(*args)
          ip_match(args[0], args[1])
        end

        # determines whether key1 matches the pattern of key2 (similar to RESTful path), key2 can contain a *.
        # For example, "/foo/bar" matches "/foo/
        def key_match(key1, key2)
          i = key2.index('*')
          return key1 == key2 if i.nil?
          return key1[0...i] == key2[0...i] if key1.size > i

          key1 == key2[0...i]
        end

        # determines whether key1 matches the pattern of key2 (similar to RESTful path), key2 can contain a *.
        # For example, "/foo/bar" matches "/foo/*", "/resource1" matches "/:resource
        def key_match2(key1, key2)
          key2 = key2.gsub('/*', '/.*')
          key2 = key2.gsub(KEY_MATCH2_PATTERN, '\1[^/]+\2')
          regex_match(key1, "^#{key2}$")
        end

        # determines determines whether key1 matches the pattern of key2 (similar to RESTful path), key2 can contain
        # a *.
        # For example, "/foo/bar" matches "/foo/*", "/resource1" matches "/{resource}"
        def key_match3(key1, key2)
          key2 = key2.gsub('/*', '/.*')
          key2 = key2.gsub(KEY_MATCH3_PATTERN, '\1[^\/]+\2')
          regex_match(key1, "^#{key2}$")
        end

        # determines whether key1 matches the pattern of key2 in regular expression.
        def regex_match(key1, key2)
          (key1 =~ /#{key2}/)&.zero? || false
        end

        # determines whether string matches the pattern in glob expression.
        def glob_match(string, pattern)
          File.fnmatch(pattern, string, File::FNM_PATHNAME)
        end

        # IPMatch determines whether IP address ip1 matches the pattern of IP address ip2, ip2 can be an IP address or
        # a CIDR pattern.
        # For example, "192.168.2.123" matches "192.168.2.0/24
        def ip_match(ip1, ip2)
          ip = IPAddr.new(ip1)
          network = IPAddr.new(ip2)
          network.include?(ip)
        rescue IPAddr::InvalidAddressError
          ip1 == ip2
        end

        # the factory method of the g(_, _) function.
        def generate_g_function(rm)
          return ->(*args) { args[0] == args[1] } unless rm

          lambda do |*args|
            name1 = args[0]
            name2 = args[1]

            if args.length == 2
              rm.has_link(name1, name2)
            else
              domain = args[2].to_s
              rm.has_link(name1, name2, domain)
            end
          end
        end
      end
    end
  end
end
