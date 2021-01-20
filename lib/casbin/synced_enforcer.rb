module Casbin
  # SyncedEnforcer wraps Enforcer and provides synchronized access.
  # It's also a drop-in replacement for Enforcer
  class SyncedEnforcer
    # starts a thread that will call load_policy every interval seconds
    def start_auto_load_policy(interval)
      # stub method
      puts "call start_auto_load_policy with interval = #{interval}"
    end

    # stops the thread started by start_auto_load_policy
    def stop_auto_load_policy
      # stub method
      puts "call stop_auto_load_policy"
    end

    # check if SyncedEnforcer is auto loading policies
    def is_auto_loading_running
      # stub method
      puts "call is_auto_loading_running"
    end
  end
end
