module Casbin
  # CoreEnforcer defines the core functionality of an enforcer.
  class CoreEnforcer
    def initialize(model, adapter, enable_log = false)
      # stub method
      puts "init CoreEnforcer"
    end

    # decides whether a "subject" can access a "object" with the operation "action",
    # input parameters are usually: (sub, obj, act).
    def enforce(*rvals)
      # stub method
      puts "call enforce with rvals = #{rvals}"
    end

    protected

    attr_accessor :model_path, :model, :fm, :eft, :adapter, :watcher, :rm, :enabled, :auto_save, :auto_build_role_links,
                  :auto_motify_watcher

    private

    attr_accessor :matcher_map
  end
end