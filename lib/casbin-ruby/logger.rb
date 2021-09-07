# frozen_string_literal: true

module Casbin
  module Logger
    module_function

    def register(logger, level)
      @logger = logger
      @level = level
    end

    def info(value)
      @logger.info(value) if @level == 'info'
    end

    def error(value)
      @logger.error(value) if @level == 'info' || @level == 'error'
    end
  end
end
