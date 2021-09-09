# frozen_string_literal: true

require 'casbin-ruby/config'

module Casbin
  module Logger
    module_function

    def info(value)
      Config.logger.info(value)
    end

    def error(value)
      Config.logger.error(value)
    end
  end
end
