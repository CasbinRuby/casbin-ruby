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
          # 'w:UTF-8' required for Windows
          File.open(file_path, 'w:UTF-8') do |file|
            file.write %w[p g].map { |root_key| policy_lines(model, root_key) }.flatten.join "\n"
          end
        end

        def policy_lines(model, root_key)
          return [] unless model.model.key?(root_key)

          model.model[root_key].map do |key, ast|
            ast.policy.map { |policy_values| "#{key}, #{policy_values.join ', '}" }
          end
        end
      end
    end
  end
end
