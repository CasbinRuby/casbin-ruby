# frozen_string_literal: true

require 'singleton'
require 'forwardable'

class ThreadLock
  include Singleton

  class << self
    extend Forwardable

    def_delegators :instance, :thread=, :lock?
  end

  attr_accessor :thread

  def lock?
    return false unless thread

    thread.active?
  end
end
