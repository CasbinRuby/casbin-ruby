# frozen_string_literal: true

require 'singleton'

class ThreadLock
  include Singleton

  class << self
    delegate :thread=, :lock?, to: :instance
  end

  attr_accessor :thread

  def lock?
    return false unless thread

    thread.active?
  end
end
