# frozen_string_literal: true

require 'logger'

module Casbin
  module Config
    class << self
      attr_writer :logger
      attr_accessor :adapter, :model, :watcher

      def setup
        yield self
      end

      def logger
        @logger ||= ::Logger.new($stdout, level: :error)
      end
    end
  end
end
