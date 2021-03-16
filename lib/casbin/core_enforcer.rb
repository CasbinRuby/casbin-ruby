# frozen_string_literal: true

require 'casbin/effect/default_effector'
require 'casbin/effect/effector'
require 'casbin/model/function_map'
require 'casbin/model/model'
require 'casbin/persist/adapters/file_adapter'
require 'casbin/rbac/default_role_manager/role_manager'
require 'casbin/util'
require 'casbin/util/builtin_operators'
require 'casbin/util/evaluator'

require 'logger'

module Casbin
  # CoreEnforcer defines the core functionality of an enforcer.
  # get_attr/set_attr methods is ported from Python as attr/attr=
  class CoreEnforcer
    def initialize(model = nil, adapter = nil, logger: Logger.new($stdout))
      if model.is_a? String
        if adapter.is_a? String
          init_with_file(model, adapter, logger: logger)
        else
          init_with_adapter(model, adapter, logger: logger)
        end
      elsif adapter.is_a? String
        raise 'Invalid parameters for enforcer.'
      else
        init_with_model_and_adapter(model, adapter, logger: logger)
      end
    end

    attr_accessor :adapter, :auto_build_role_links, :auto_save, :effector, :enabled, :role_manager, :watcher
    attr_reader :model

    # initializes an enforcer with a model file and a policy file.
    def init_with_file(model_path, policy_path, logger: Logger.new($stdout))
      a = Persist::Adapters::FileAdapter.new(policy_path)
      init_with_adapter(model_path, a, logger: logger)
    end

    # initializes an enforcer with a database adapter.
    def init_with_adapter(model_path, adapter = nil, logger: Logger.new($stdout))
      m = new_model(model_path)
      init_with_model_and_adapter(m, adapter, logger: logger)

      self.model_path = model_path
    end

    # initializes an enforcer with a model and a database adapter.
    def init_with_model_and_adapter(m, adapter = nil, logger: Logger.new($stdout))
      self.adapter = adapter

      self.model = m
      model.print_model

      init(logger: logger)

      # Do not initialize the full policy when using a filtered adapter
      load_policy if adapter && !filtered?
    end

    # creates a model.
    def self.new_model(path = '', text = '', logger: Logger.new($stdout))
      m = Model::Model.new logger: logger
      if path.length.positive?
        m.load_model(path)
      else
        m.load_model_from_text(text)
      end

      m
    end

    def new_model(*args)
      self.class.new_model(*args)
    end

    # reloads the model from the model CONF file.
    # Because the policy is attached to a model, so the policy is invalidated and needs to be reloaded by calling
    # load_policy.
    def load_model
      self.model = new_model
      model.load_model model_path
      model.print_model
    end

    # sets the current model.
    def model=(m)
      @model = m
      self.fm = Model::FunctionMap.load_function_map
    end

    # clears all policy.
    def clear_policy
      model.clear_policy
    end

    # reloads the policy from file/database.
    def load_policy
      model.clear_policy
      adapter.load_policy model

      model.print_policy
      build_role_links if auto_build_role_links
    end

    # reloads a filtered policy from file/database.
    def load_filtered_policy(filter)
      model.clear_policy

      raise ArgumentError, 'filtered policies are not supported by this adapter' unless adapter.respond_to?(:filtered?)

      adapter.load_filtered_policy(model, filter)
      model.print_policy
      build_role_links if auto_build_role_links
    end

    # appends a filtered policy from file/database.
    def load_increment_filtered_policy(filter)
      raise ArgumentError, 'filtered policies are not supported by this adapter' unless adapter.respond_to?(:filtered?)

      adapter.load_filtered_policy(model, filter)
      model.print_policy
      build_role_links if auto_build_role_links
    end

    # returns true if the loaded policy has been filtered.
    def filtered?
      adapter.respond_to?(:filtered?) && adapter.filtered?
    end

    def save_policy
      raise 'cannot save a filtered policy' if filtered?

      adapter.save_policy(model)

      watcher&.update
    end

    alias enabled? enabled

    # manually rebuild the role inheritance relations.
    def build_role_links
      role_manager.clear
      model.build_role_links(role_manager)
    end

    # decides whether a "subject" can access a "object" with the operation "action",
    # input parameters are usually: (sub, obj, act).
    def enforce(*rvals)
      return false unless enabled?

      raise 'model is undefined' unless model.model['m']&.key?('m')

      r_tokens = model.model['r']['r'].tokens
      raise 'invalid request size' if r_tokens.length != rvals.length

      p_tokens = model.model['p']['p'].tokens
      effector_model = model.model['e']['e'].value
      exp_string = model.model['m']['m'].value

      has_eval = Util.has_eval(exp_string)
      expression = exp_string

      policy_effects = Set.new
      matcher_results = Set.new

      r_parameters = load_params(r_tokens, rvals)

      policy_rules = model.get_policy('p', 'p')

      if policy_rules.any?
        policy_rules.each do |pvals|
          raise 'invalid policy size' if p_tokens.length != pvals.length

          p_parameters = load_params(p_tokens, pvals)
          parameters = r_parameters.merge p_parameters
          expression = Util.replace_eval(exp_string, p_parameters) if has_eval

          result = evaluate expression, functions, parameters

          case result
          when TrueClass, FalseClass
            unless result
              policy_effects.add(Effect::Effector::INDETERMINATE)
              next
            end
          when Numeric
            if result.zero?
              policy_effects.add(Effect::Effector::INDETERMINATE)
              next
            else
              matcher_results.add(result)
            end
          else
            raise 'matcher result should be true, false or a number'
          end

          policy_effects.add policy_effect(parameters)

          break if effector_model == 'priority(p_eft) || deny'
        end
      else
        raise 'please make sure rule exists in policy when using eval() in matcher' if has_eval

        parameters = r_parameters
        p_tokens.each { |token| parameters[token] = '' }

        result = evaluate expression, functions, parameters

        policy_effects.add result ? Effect::Effector::ALLOW : Effect::Effector::INDETERMINATE
      end

      result = effector.merge_effects(effector_model, policy_effects, matcher_results)

      log_request(rvals, result)

      result
    end

    protected

    attr_accessor :model_path, :fm, :auto_motify_watcher
    attr_reader :logger

    private

    attr_accessor :matcher_map

    def init(logger: Logger.new($stdout))
      self.role_manager = Rbac::DefaultRoleManager::RoleManager.new 10, logger: logger
      self.effector = Effect::DefaultEffector.new

      self.enabled = true
      self.auto_save = true
      self.auto_build_role_links = true

      @logger = logger
    end

    def evaluate(expr, funcs = {}, params = {})
      Util::Evaluator.eval expr, funcs, params
    end

    def load_params(tokens, values)
      params = {}
      tokens.each_with_index { |token, i| params[token] = values[i] }

      params
    end

    def functions
      functions = fm.get_functions

      if model.model.key? 'g'
        model.model['g'].each do |key, ast|
          rm = ast.rm
          functions[key] = Util::BuiltinOperators.generate_g_function(rm)
        end
      end

      functions
    end

    def policy_effect(params)
      if params.key? 'p_eft'
        case params['p_eft']
        when 'allow'
          Effect::Effector::ALLOW
        when 'deny'
          Effect::Effector::DENY
        else
          Effect::Effector::INDETERMINATE
        end
      else
        Effect::Effector::ALLOW
      end
    end

    def log_request(rvals, result)
      req_str = "Request: #{rvals.map(&:to_s).join ', '} ---> #{result}"

      if result
        logger.info(req_str)
      else
        # leaving this in error for now, if it's very noise this can be changed to info or debug
        logger.error(req_str)
      end
    end
  end
end
