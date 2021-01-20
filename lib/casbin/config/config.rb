# represents an implementation of the ConfigInterface
module Casbin
  module Config
    class Config
      def self.new_config(conf_name)
        # stub method
        puts "call new_config with conf_name = #{conf_name}"
      end

      def set(key, value)
        # stub method
        puts "call get with key = #{key} value = #{value}"
      end

      # section.key or key
      def get(key)
        # stub method
        puts "call get with key = #{key}"
      end
    end
  end
end
