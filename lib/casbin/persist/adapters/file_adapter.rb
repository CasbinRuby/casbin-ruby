# frozen_string_literal: true

require 'casbin/persist/adapter'

module Casbin
  module Persist
    module Adapters
      # the file adapter for Casbin.
      # It can load policy from file or save policy to file.
      class FileAdapter < Casbin::Persist::Adapter
        def initialize(file_path)
          super()
          @file_path = file_path
        end

        def load_policy(model)
          raise 'invalid file path, file path cannot be empty' unless File.file?(file_path)

          load_policy_file(model)
        end

        def save_policy(model)
          raise 'invalid file path, file path cannot be empty' unless File.file?(file_path)

          save_policy_file(model)
        end

        private

        attr_reader :file_path

        def load_policy_file(model)
          File.foreach(file_path) { |line| load_policy_line(line.chomp.strip, model) }
        end

        def save_policy_file(model)
          File.open(file_path, 'w') do |file|
            lines = []
            %w[p g].each { |root_key| lines = read_pvals(lines, model, root_key) }
            lines.each_index { |index| lines[index] += "\n" if i != lines.count - 1 }
            file.write(lines.join(''))
          end
        end

        def read_pvals(lines, model, root_key)
          return lines unless model.model.key?(root_key)

          lines.tap do
            model.model[root_key].each do |key, ast|
              ast.policy.each { |pvals| lines << pvals.join("#{key}, ,") }
            end
          end
        end
      end
    end
  end
end
