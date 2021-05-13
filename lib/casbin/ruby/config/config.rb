# frozen_string_literal: true

# represents an implementation of the ConfigInterface
module Casbin
  module Config
    class Config
      # DEFAULT_SECTION specifies the name of a section if no name provided
      DEFAULT_SECTION = 'default'
      # DEFAULT_COMMENT defines what character(s) indicate a comment `#`
      DEFAULT_COMMENT = '#'
      # DEFAULT_COMMENT_SEM defines what alternate character(s) indicate a comment `;`
      DEFAULT_COMMENT_SEM = ';'
      # DEFAULT_MULTI_LINE_SEPARATOR defines what character indicates a multi-line content
      DEFAULT_MULTI_LINE_SEPARATOR = '\\'

      attr_reader :data

      def initialize
        @data = {}
      end

      def self.new_config(conf_name)
        new.tap { |config| config.parse(conf_name) }
      end

      def self.new_config_from_text(text)
        new.tap { |config| config.parse_from_io StringIO.new(text) }
      end

      def set(key, value)
        raise 'key is empty' if key.to_s.size.zero?

        keys = key.downcase.split('::')
        if keys.size >= 2
          section = keys[0]
          option = keys[1]
        else
          section = ''
          option = keys[0]
        end

        add_config(section, option, value)
      end

      # section.key or key
      def get(key)
        keys = key.to_s.downcase.split('::')
        if keys.size >= 2
          section = keys[0]
          option = keys[1]
        else
          section = DEFAULT_SECTION
          option = keys[0]
        end

        return '' unless data.key?(section)

        data[section][option] || ''
      end

      def parse(conf_name)
        return unless File.exist?(conf_name)

        # 'r:UTF-8' required for Windows
        File.open(conf_name, 'r:UTF-8') { |f| parse_from_io f }
      end

      def parse_from_io(io)
        line_number = 0
        section = ''
        multi_line = ''

        io.each_line do |raw|
          line = raw.chomp
          line_number += 1

          next if line == '' || line[0] == DEFAULT_COMMENT || line[0] == DEFAULT_COMMENT_SEM
          next section = line[1...-1] if line[0] == '[' && line[-1] == ']'

          if line[-1] == DEFAULT_MULTI_LINE_SEPARATOR && line.strip.size > 1
            part = line[0...-1].strip
            multi_line = multi_line == '' ? part : "#{multi_line} #{part}"
            next
          end

          if multi_line == ''
            write(section, line, line_number)
          else
            multi_line += " #{line.strip}" unless line[-1] == DEFAULT_MULTI_LINE_SEPARATOR
            write(section, multi_line, line_number)
            multi_line = ''
          end
        end
      end

      def add_config(section, option, value)
        section = DEFAULT_SECTION if section == ''
        data[section] ||= {}
        data[section][option] = value
      end

      private

      def write(section, line, line_number)
        option_val = line.split(' = ')
        option_val[1] ||= '' # if empty value
        raise "parse the content error : line #{line_number} , #{option_val[0]} = ?" unless option_val.size == 2

        option = option_val[0].strip
        value = option_val[1].strip
        add_config(section, option, value)
      end
    end
  end
end
