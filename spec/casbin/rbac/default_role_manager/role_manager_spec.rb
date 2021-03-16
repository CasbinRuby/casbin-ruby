# frozen_string_literal: true

require 'logger'
require 'casbin/rbac/default_role_manager/role_manager'
require 'casbin/util/builtin_operators'

describe Casbin::Rbac::DefaultRoleManager::RoleManager do
  let(:role_manager) { described_class.new(1) }

  it '#add_matching_func' do
    role_manager.add_matching_func(-> { 'simple' })
    expect(role_manager.matching_func).not_to be_nil
  end

  describe '#create_role' do
    it 'when no matching_func' do
      role_manager.create_role('test_role')
      expect(role_manager.all_roles).to have_key('test_role')
    end

    it 'when matching_func truthy' do
      role_manager.add_matching_func(->(_name, _key) { true })
      role_manager.create_role('test_role')
      role_manager.create_role('test_role1')

      expect(role_manager.all_roles['test_role1'].has_direct_role('test_role')).to be_truthy
    end

    it 'when matching_func falsey' do
      role_manager.add_matching_func(->(_name, _key) { false })
      role_manager.create_role('test_role')
      role_manager.create_role('test_role1')
      expect(role_manager.all_roles['test_role1'].has_direct_role('test_role')).to be_falsey
    end
  end

  describe '#has_role' do
    it 'when no matching_func' do
      expect(role_manager.has_role('test_role')).to be_falsey
      role_manager.create_role('test_role')
      expect(role_manager.has_role('test_role')).to be_truthy
    end

    it 'when matching_func truthy' do
      role_manager.add_matching_func(->(_name, _key) { true })
      role_manager.create_role('test_role')
      role_manager.create_role('test_role1')
      expect(role_manager.all_roles['test_role1'].has_direct_role('test_role')).to be_truthy
    end

    it 'when matching_func falsey' do
      role_manager.add_matching_func(->(_name, _key) { false })
      role_manager.create_role('test_role')
      role_manager.create_role('test_role1')
      expect(role_manager.all_roles['test_role1'].has_direct_role('test_role')).to be_falsey
    end
  end

  it '#clear' do
    role_manager.create_role('test_role')
    expect(role_manager.all_roles).not_to be_empty

    role_manager.clear
    expect(role_manager.all_roles).to be_empty
  end

  it '#add_link' do
    role_manager.add_link('test1', 'test2', 'domain')
    expect(role_manager.has_role('domain::test1')).to be_truthy
    expect(role_manager.all_roles['domain::test1'].has_direct_role('domain::test2')).to be_truthy
  end

  it '#delete_link' do
    role_manager.add_link('test1', 'test2', 'domain')
    role_manager.delete_link('test1', 'test2', 'domain')
    expect(role_manager.all_roles['domain::test1'].has_direct_role('domain::test2')).to be_falsey
  end

  describe '#has_link' do
    it 'when same name' do
      expect(role_manager.has_link('test1', 'test1', 'domain')).to be_truthy
    end

    it 'when not have role' do
      expect(role_manager.has_link('test1', 'test2', 'domain')).to be_falsey
    end

    it 'when have role' do
      role_manager.add_link('test1', 'test2', 'domain')
      expect(role_manager.has_link('test1', 'test2', 'domain')).to be_truthy
    end

    context 'with matching function' do
      before do
        role_manager.add_matching_func ->(key1, key2) { Casbin::Util::BuiltinOperators.key_match2 key1, key2 }
        role_manager.add_link '/book/:id', 'book_admin'
      end

      it 'correctly matches' do
        expect(role_manager.has_link('/book/1', 'book_admin')).to be_truthy
        expect(role_manager.has_link('/book/2', 'book_admin')).to be_truthy
        expect(role_manager.has_link('/other/1', 'book_admin')).to be_falsey
      end
    end
  end

  it '#get_roles' do
    role_manager.create_role('test_role')
    role_manager.create_role('test_rol1')
    role_manager.all_roles['test_role'].add_role(role_manager.create_role('test_role'))
    role_manager.all_roles['test_rol1'].add_role(role_manager.create_role('test_role'))
    roles = role_manager.get_roles('test_role')
    expect(roles.size).to eq 1
    expect(roles[0]).to eq 'test_role'
  end

  it '#get_users' do
    role_manager.create_role('test_role')
    role_manager.create_role('test_role1')
    role_manager.all_roles['test_role'].add_role(role_manager.create_role('test_role'))
    role_manager.all_roles['test_role1'].add_role(role_manager.create_role('test_role'))
    expect(role_manager.get_users('test_role')).to match_array(%w[test_role test_role1])
  end

  it '#print_roles' do
    role_manager.create_role('test_role')
    role_manager.create_role('test_rol2')
    allow(Logger).to receive(:info).with('test_role, test_rol2')
    role_manager.print_roles
  end
end
