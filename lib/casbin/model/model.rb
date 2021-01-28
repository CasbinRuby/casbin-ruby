# frozen_string_literal: true

require 'casbin/model/policy'
require 'casbin/model/assertion'
require 'casbin/config/config'
require 'casbin/util'

module Casbin
  module Model
    class Model < Casbin::Model::Policy
      SECTION_NAME_MAP = {
        r: 'request_definition',
        p: 'policy_definition',
        g: 'role_definition',
        e: 'policy_effect',
        m: 'matchers'
      }.freeze

      def load_model(path)
        cfg = Casbin::Config::Config.new_config(path)
        SECTION_NAME_MAP.each_key { |key| load_section(cfg, key.to_s) }
      end

      def add_def(sec, key, value)
        return false if value == ''

        ast = Assertion.new(key: key, value: value)
        %w[r p].include?(sec) ? ast_tokens_set(ast, key) : model_sec_set(ast)

        model[sec] ||= {}
        model[sec][key] = ast
      end

      private

      def ast_tokens_set(ast, key)
        ast.tokens = ast.value.split(',')
        ast.tokens.each_with_index { |token, i| ast.tokens[i] = "#{key}_#{token.strip}" }
      end

      def model_sec_set(ast)
        ast.value = Casbin::Util.remove_comments(Casbin::Util.escape_assertion(ast.value))
      end

      def load_section(cfg, sec)
        loop.with_index do |_, i|
          break unless load_assertion(cfg, sec, "#{sec}#{get_key_suffix(i + 1)}")
        end
      end

      def load_assertion(cfg, sec, key)
        value = cfg.get("#{SECTION_NAME_MAP[sec.to_sym]}::#{key}")
        add_def(sec, key, value)
      end

      def get_key_suffix(i)
        i == 1 ? '' : i
      end
    end
  end
end
