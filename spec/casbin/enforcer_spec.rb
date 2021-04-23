# frozen_string_literal: true

require 'casbin/enforcer'
require 'casbin/util'
require 'support/model_helper'

describe Casbin::Enforcer do
  describe 'basic' do
    let(:enf) { described_class.new(model_config('basic'), policy_file('basic')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'write')).to be_truthy
      expect(enf.enforce('bob', 'data1', 'write')).to be_falsey
    end

    it '#enforce_ex' do
      expect(enf.enforce_ex('alice', 'data1', 'read')).to match_array([true, %w[alice data1 read]])
      expect(enf.enforce_ex('alice', 'data2', 'read')).to match_array([false, []])
      expect(enf.enforce_ex('bob', 'data2', 'write')).to match_array([true, %w[bob data2 write]])
      expect(enf.enforce_ex('bob', 'data1', 'write')).to match_array([false, []])
    end

    it '#load_model' do
      enf.model = nil
      expect(enf.model).to be_nil
      enf.load_model
      expect(enf.model).not_to be_nil
    end
  end

  describe 'basic without spaces' do
    let(:enf) { described_class.new(model_config('basic_without_spaces'), policy_file('basic')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data1', 'write')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'read')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'write')).to be_falsey
      expect(enf.enforce('bob', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data1', 'write')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'write')).to be_truthy
    end
  end

  describe 'basic with root' do
    let(:enf) { described_class.new(model_config('basic_with_root'), policy_file('basic')) }

    it '#enforce' do
      expect(enf.enforce('root', 'any', 'any')).to be_truthy
    end
  end

  describe 'basic without resources' do
    let(:enf) { described_class.new(model_config('basic_without_resources'), policy_file('basic_without_resources')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'read')).to be_truthy
      expect(enf.enforce('alice', 'write')).to be_falsey
      expect(enf.enforce('bob', 'write')).to be_truthy
      expect(enf.enforce('bob', 'read')).to be_falsey
    end
  end

  describe 'basic without users' do
    let(:enf) { described_class.new(model_config('basic_without_users'), policy_file('basic_without_users')) }

    it '#enforce' do
      expect(enf.enforce('data1', 'read')).to be_truthy
      expect(enf.enforce('data1', 'write')).to be_falsey
      expect(enf.enforce('data2', 'write')).to be_truthy
      expect(enf.enforce('data2', 'read')).to be_falsey
    end
  end

  describe 'ip match' do
    let(:enf) { described_class.new(model_config('ip'), policy_file('ip')) }

    it '#enforce' do
      expect(enf.enforce('192.168.2.1', 'data1', 'read')).to be_truthy
      expect(enf.enforce('192.168.3.1', 'data1', 'read')).to be_falsey
    end
  end

  describe 'key match' do
    let(:enf) { described_class.new(model_config('key'), policy_file('key')) }

    it '#enforce' do
      expect(enf.enforce('alice', '/alice_data/test', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/bob_data/test', 'GET')).to be_falsey
      expect(enf.enforce('cathy', '/cathy_data', 'GET')).to be_truthy
      expect(enf.enforce('cathy', '/cathy_data', 'POST')).to be_truthy
      expect(enf.enforce('cathy', '/cathy_data/12', 'POST')).to be_falsey
    end
  end

  describe 'key match2' do
    let(:enf) { described_class.new(model_config('key2'), policy_file('key2')) }

    it '#enforce' do
      expect(enf.enforce('alice', '/alice_data/resource', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/alice_data2/123/using/456', 'GET')).to be_truthy
    end
  end

  describe 'priority' do
    let(:enf) { described_class.new(model_config('priorities/priority'), policy_file('priorities/priority')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data1', 'write')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'read')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'write')).to be_falsey

      expect(enf.enforce('bob', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data1', 'write')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'read')).to be_truthy
      expect(enf.enforce('bob', 'data2', 'write')).to be_falsey
    end
  end

  describe 'priority indeterminate' do
    let(:enf) { described_class.new(model_config('priorities/priority'), policy_file('priorities/indeterminate')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_falsey
    end
  end

  describe 'rbac' do
    let(:enf) { described_class.new(model_config('rbac'), policy_file('rbac')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('bob', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'write')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'write')).to be_truthy
      expect(enf.enforce('bogus', 'data2', 'write')).to be_falsey
    end
  end

  describe 'rbac empty policy' do
    let(:enf) { described_class.new(model_config('rbac'), policy_file('empty')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'write')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'read')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'write')).to be_falsey
    end
  end

  describe 'rbac with_deny' do
    let(:enf) { described_class.new(model_config('rbac_with_deny'), policy_file('rbac_with_deny')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('bob', 'data2', 'write')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'write')).to be_falsey
    end
  end

  describe 'rbac with domains' do
    let(:enf) { described_class.new(model_config('rbac_with_domains'), policy_file('rbac_with_domains')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'domain1', 'data1', 'read')).to be_truthy
      expect(enf.enforce('alice', 'domain1', 'data1', 'write')).to be_truthy
      expect(enf.enforce('alice', 'domain1', 'data2', 'read')).to be_falsey
      expect(enf.enforce('alice', 'domain1', 'data2', 'write')).to be_falsey

      expect(enf.enforce('bob', 'domain2', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'domain2', 'data1', 'write')).to be_falsey
      expect(enf.enforce('bob', 'domain2', 'data2', 'read')).to be_truthy
      expect(enf.enforce('bob', 'domain2', 'data2', 'write')).to be_truthy
    end
  end

  describe 'rbac with not deny' do
    let(:enf) { described_class.new(model_config('rbac_with_not_deny'), policy_file('rbac_with_deny')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data2', 'write')).to be_falsey
    end
  end

  describe 'rbac with resource roles' do
    let(:enf) { described_class.new(model_config('rbac_with_resource_roles'), policy_file('rbac_with_resource_roles')) }

    it '#enforce' do
      expect(enf.enforce('alice', 'data1', 'read')).to be_truthy
      expect(enf.enforce('alice', 'data1', 'write')).to be_truthy
      expect(enf.enforce('alice', 'data2', 'read')).to be_falsey
      expect(enf.enforce('alice', 'data2', 'write')).to be_truthy

      expect(enf.enforce('bob', 'data1', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data1', 'write')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'read')).to be_falsey
      expect(enf.enforce('bob', 'data2', 'write')).to be_truthy
    end
  end

  describe 'rbac with pattern' do
    let(:enf) { described_class.new(model_config('rbac_with_pattern'), policy_file('rbac_with_pattern')) }

    it '#enforce' do
      # set matching function to key_match2
      enf.add_named_matching_func('g2', ->(key1, key2) { Casbin::Util::BuiltinOperators.key_match2(key1, key2) })

      expect(enf.enforce('alice', '/book/1', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/book/2', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/pen/1', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/pen/2', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/book/1', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/book/2', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/pen/1', 'GET')).to be_truthy
      expect(enf.enforce('bob', '/pen/2', 'GET')).to be_truthy

      # replace key_match2 with key_match3
      enf.add_named_matching_func('g2', ->(key1, key2) { Casbin::Util::BuiltinOperators.key_match3(key1, key2) })
      expect(enf.enforce('alice', '/book2/1', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/book2/2', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/pen2/1', 'GET')).to be_truthy
      expect(enf.enforce('alice', '/pen2/2', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/book2/1', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/book2/2', 'GET')).to be_falsey
      expect(enf.enforce('bob', '/pen2/1', 'GET')).to be_truthy
      expect(enf.enforce('bob', '/pen2/2', 'GET')).to be_truthy
    end
  end

  describe 'abac log enabled' do
    let(:enf) { described_class.new(model_config('abac')) }

    it '#enforce' do
      sub = 'alice'
      obj = { 'Owner' => 'alice', 'id' => 'data1' }
      expect(enf.enforce(sub, obj, 'write')).to be_truthy
    end
  end

  describe 'abac with sub rule' do
    let(:enf) { described_class.new(model_config('abac_rule'), policy_file('abac_rule')) }

    it '#enforce' do
      sub1 = { 'name' => 'alice', 'age' => 16 }
      sub2 = { 'name' => 'bob', 'age' => 20 }
      sub3 = { 'name' => 'alice', 'age' => 65 }

      expect(enf.enforce(sub1, '/data1', 'read')).to be_falsey
      expect(enf.enforce(sub1, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub1, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub1, '/data2', 'write')).to be_truthy

      expect(enf.enforce(sub2, '/data1', 'read')).to be_truthy
      expect(enf.enforce(sub2, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub2, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub2, '/data2', 'write')).to be_truthy

      expect(enf.enforce(sub3, '/data1', 'read')).to be_truthy
      expect(enf.enforce(sub3, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub3, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub3, '/data2', 'write')).to be_falsey
    end
  end

  describe 'abac with multiple sub rules' do
    let(:enf) { described_class.new(model_config('abac_multiple_rules'), policy_file('abac_multiple_rules')) }

    it '#enforce' do
      sub1 = { 'name' => 'alice', 'age' => 16 }
      sub2 = { 'name' => 'bob', 'age' => 20 }
      sub3 = { 'name' => 'alice', 'age' => 65 }
      sub4 = { 'name' => 'bob', 'age' => 35 }

      expect(enf.enforce(sub1, '/data1', 'read')).to be_falsey
      expect(enf.enforce(sub1, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub1, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub1, '/data2', 'write')).to be_falsey

      expect(enf.enforce(sub2, '/data1', 'read')).to be_falsey
      expect(enf.enforce(sub2, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub2, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub2, '/data2', 'write')).to be_truthy

      expect(enf.enforce(sub3, '/data1', 'read')).to be_truthy
      expect(enf.enforce(sub3, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub3, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub3, '/data2', 'write')).to be_falsey

      expect(enf.enforce(sub4, '/data1', 'read')).to be_falsey
      expect(enf.enforce(sub4, '/data2', 'read')).to be_falsey
      expect(enf.enforce(sub4, '/data1', 'write')).to be_falsey
      expect(enf.enforce(sub4, '/data2', 'write')).to be_truthy
    end
  end
end
