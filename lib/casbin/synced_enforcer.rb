# frozen_string_literal: true

require 'casbin/util/thread_lock'

module Casbin
  # SyncedEnforcer wraps Enforcer and provides synchronized access.
  # It's also a drop-in replacement for Enforcer
  class SyncedEnforcer < Enforcer
    # check if SyncedEnforcer is auto loading policies
    def auto_loading_running?
      ThreadLock.lock?
    end

    # starts a thread that will call load_policy every interval seconds
    def start_auto_load_policy(interval)
      return if auto_loading_running?

      ThreadLock.thread = Thread.new { auto_load_policy(interval) }
    end

    # stops the thread started by start_auto_load_policy
    def stop_auto_load_policy
      ThreadLock.thread.exit if auto_loading_running?
    end

    def build_incremental_role_links(op, ptype, rules)
      model.build_incremental_role_links(role_manager, op, 'g', ptype, rules)
    end

    private

    def auto_load_policy(interval)
      while auto_loading_running?
        sleep(interval)
        load_policy
      end
    end
  end
end
