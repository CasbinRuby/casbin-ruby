# frozen_string_literal: true

require 'casbin-ruby/effect/default_effector'
require 'casbin-ruby/effect/effector'
require 'casbin-ruby/model/function_map'
require 'casbin-ruby/model/model'
require 'casbin-ruby/persist/adapters/file_adapter'
require 'casbin-ruby/rbac/default_role_manager/role_manager'
require 'casbin-ruby/util'
require 'casbin-ruby/util/builtin_operators'
require 'casbin-ruby/util/evaluator'
require 'casbin-ruby/logger'
require 'casbin-ruby/config'

module Casbin
  # CoreEnforcer defines the core functionality of an enforcer.
  # get_attr/set_attr methods is ported from Python as attr/attr=
  class CoreEnforcer
    def initialize(model = nil, adapter = nil, watcher = nil)
      model ||= Config.model
      adapter ||= Config.adapter
      @watcher = watcher || Config.watcher

      if model.is_a? String
        if adapter.is_a? String
          init_with_file(model, adapter)
        else
          init_with_adapter(model, adapter)
        end
      elsif adapter.is_a? String
        raise 'Invalid parameters for enforcer.'
      else
        init_with_model_and_adapter(model, adapter)
      end
    end

    attr_accessor :auto_build_role_links, :auto_save, :effector, :enabled, :rm_map
    attr_reader :adapter, :model, :watcher

    # initializes an enforcer with a model file and a policy file.
    def init_with_file(model_path, policy_path)
      a = Persist::Adapters::FileAdapter.new(policy_path)
      init_with_adapter(model_path, a)
    end

    # initializes an enforcer with a database adapter.
    def init_with_adapter(model_path, adapter = nil)
      m = new_model(model_path)
      init_with_model_and_adapter(m, adapter)

      self.model_path = model_path
    end

    # initializes an enforcer with a model and a database adapter.
    def init_with_model_and_adapter(m, adapter = nil)
      if !m.is_a?(Model::Model) || (!adapter.nil? && !adapter.is_a?(Persist::Adapter))
        raise StandardError, 'Invalid parameters for enforcer.'
      end

      self.adapter = adapter

      self.model = m
      model.print_model
      self.fm = Model::FunctionMap.load_function_map

      init

      # Do not initialize the full policy when using a filtered adapter
      load_policy if adapter && !filtered?
    end

    # creates a model.
    def self.new_model(path = '', text = '')
      m = Model::Model.new
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
      self.fm = Model::FunctionMap.load_function_map
    end

    # sets the current model.
    def model=(m)
      @model = m
      self.fm = Model::FunctionMap.load_function_map
    end

    # gets the current role manager.
    def role_manager
      rm_map['g']
    end

    # sets the current role manager.
    def role_manager=(rm)
      rm_map['g'] = rm
    end

    # clears all policy.
    def clear_policy
      model.clear_policy
    end

    # reloads the policy from file/database.
    def load_policy
      model.clear_policy
      adapter.load_policy model

      init_rm_map
      model.print_policy
      build_role_links if auto_build_role_links
    end

    # reloads a filtered policy from file/database.
    def load_filtered_policy(filter)
      model.clear_policy

      raise ArgumentError, 'filtered policies are not supported by this adapter' unless adapter.respond_to?(:filtered?)

      adapter.load_filtered_policy(model, filter)
      init_rm_map
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

    # changes the enforcing state of Casbin,
    # when Casbin is disabled, all access will be allowed by the Enforce() function.
    def enable_enforce(enabled = true)
      self.enabled = enabled
    end

    # controls whether to save a policy rule automatically to the adapter when it is added or removed.
    def enable_auto_save(auto_save)
      self.auto_save = auto_save
    end

    # controls whether to rebuild the role inheritance relations when a role is added or deleted.
    def enable_auto_build_role_links(auto_build_role_links)
      self.auto_build_role_links = auto_build_role_links
    end

    # manually rebuild the role inheritance relations.
    def build_role_links
      rm_map.each_value(&:clear)
      model.build_role_links(rm_map)
    end

    # add_named_matching_func add MatchingFunc by ptype RoleManager
    def add_named_matching_func(ptype, fn)
      rm_map[ptype]&.add_matching_func(fn)
    end

    # add_named_domain_matching_func add MatchingFunc by ptype to RoleManager
    def add_named_domain_matching_func(ptype, fn)
      rm_map[ptype]&.add_domain_matching_func(fn)
    end

    # decides whether a "subject" can access a "object" with the operation "action",
    # input parameters are usually: (sub, obj, act).
    def enforce(*rvals)
      enforce_ex(*rvals)[0]
    end

    # decides whether a "subject" can access a "object" with the operation "action",
    # input parameters are usually: (sub, obj, act).
    # return judge result with reason
    def enforce_ex(*rvals)
      return [false, []] unless enabled?

      raise 'model is undefined' unless model.model&.key?('m')
      raise 'model is undefined' unless model.model['m']&.key?('m')

      r_tokens = model.model['r']['r'].tokens
      p_tokens = model.model['p']['p'].tokens
      raise StandardError, 'invalid request size' unless r_tokens.size == rvals.size

      exp_string = model.model['m']['m'].value
      has_eval = Util.has_eval(exp_string)
      expression = exp_string
      policy_effects = Set.new
      r_parameters = load_params(r_tokens, rvals)
      policy_len = model.model['p']['p'].policy.size
      explain_index = -1
      if policy_len.positive?
        model.model['p']['p'].policy.each_with_index do |pvals, i|
          raise StandardError, 'invalid policy size' unless p_tokens.size == pvals.size

          p_parameters = load_params(p_tokens, pvals)
          parameters = r_parameters.merge(p_parameters)

          if has_eval
            rule_names = Util.get_eval_value(exp_string)
            rules = rule_names.map { |rule_name| Util.escape_assertion(p_parameters[rule_name]) }
            expression = Util.replace_eval(exp_string, rules)
          end

          result = evaluate(expression, functions, parameters)
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
            end
          else
            raise 'matcher result should be true, false or a number'
          end

          if parameters.keys.include?('p_eft')
            case parameters['p_eft']
            when 'allow'
              policy_effects.add(Effect::Effector::ALLOW)
            when 'deny'
              policy_effects.add(Effect::Effector::DENY)
            else
              policy_effects.add(Effect::Effector::INDETERMINATE)
            end
          else
            policy_effects.add(Effect::Effector::ALLOW)
          end

          if effector.intermediate_effect(policy_effects) != Effect::Effector::INDETERMINATE
            explain_index = i
            break
          end
        end

      else
        raise 'please make sure rule exists in policy when using eval() in matcher' if has_eval

        parameters = r_parameters.clone
        model.model['p']['p'].tokens.each { |token| parameters[token] = '' }
        result = evaluate(expression, functions, parameters)
        if result
          policy_effects.add(Effect::Effector::ALLOW)
        else
          policy_effects.add(Effect::Effector::INDETERMINATE)
        end
      end

      final_effect = effector.final_effect(policy_effects)
      result = Effect::DefaultEffector.effect_to_bool(final_effect)

      # Log request.
      log_request(rvals, result)

      explain_rule = []
      explain_rule = model.model['p']['p'].policy[explain_index] if explain_index != -1 && explain_index < policy_len
      [result, explain_rule]
    end

    protected

    attr_accessor :model_path, :fm, :auto_motify_watcher

    private

    attr_accessor :matcher_map
    attr_writer :adapter

    def init
      self.rm_map = {}
      self.effector = Effect::DefaultEffector.get_effector(model.model['e']['e'].value)

      self.enabled = true
      self.auto_save = true
      self.auto_build_role_links = true

      init_rm_map
    end

    def evaluate(expr, funcs = {}, params = {})
      Util::Evaluator.eval(expr, funcs, params)
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

    def log_request(rvals, result)
      req_str = "Request: #{rvals.map(&:to_s).join ', '} ---> #{result}"

      if result
        Logger.info(req_str)
      else
        # leaving this in error for now, if it's very noise this can be changed to info or debug
        Logger.error(req_str)
      end
    end

    def init_rm_map
      return unless model.model.keys.include?('g')

      model.model['g'].each_key do |ptype|
        rm_map[ptype] = Rbac::DefaultRoleManager::RoleManager.new(10)
      end
    end
  end
end
