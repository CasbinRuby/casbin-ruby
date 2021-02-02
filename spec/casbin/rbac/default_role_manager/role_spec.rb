# frozen_string_literal: true

require 'casbin/rbac/default_role_manager/role'

describe Casbin::Rbac::DefaultRoleManager::Role do
  let(:role) { described_class.new('test_role') }
  let(:new_role) { described_class.new('new_role') }

  describe '#add_role' do
    it 'when new role' do
      role.add_role(new_role)
      expect(role.roles).to match_array([new_role])
    end

    it 'when role exist' do
      role.add_role(new_role)
      role.add_role(new_role)
      expect(role.roles).to match_array([new_role])
    end
  end

  it '#delete_role' do
    role.add_role(new_role)
    expect(role.roles).not_to be_empty

    role.delete_role(new_role)
    expect(role.roles).to be_empty
  end

  describe '#has_role' do
    it 'when root name' do
      expect(role.has_role(role.name, 1)).to be_truthy
    end

    it 'when hierarchy_level incorrect' do
      role.add_role(new_role)
      expect(role.has_role(new_role.name, 0)).to be_falsey
      expect(role.has_role(new_role.name, -1)).to be_falsey
      expect(role.has_role(new_role.name, 'text')).to be_falsey
    end

    it 'when role deep' do
      deep_role = described_class.new('depp_role')
      new_role.add_role(deep_role)
      role.add_role(new_role)
      expect(role.has_role(new_role.name, 1)).to be_truthy
      expect(role.has_role(deep_role.name, 1)).to be_falsey
      expect(role.has_role(deep_role.name, 2)).to be_truthy
      expect(role.has_role(deep_role.name, 5)).to be_truthy
    end
  end

  it '#get_roles' do
    deep_role = described_class.new('depp_role')
    new_role.add_role(deep_role)
    role.add_role(new_role)
    expect(role.get_roles).to match_array([new_role.name])
  end

  it '#has_direct_role' do
    role.add_role(new_role)
    expect(role.has_direct_role(new_role.name)).to be_truthy
    expect(role.has_direct_role('not_exist')).to be_falsey
  end

  describe '#to_string' do
    it 'when roles empty' do
      expect(role.to_string).to be_nil
    end

    it 'when one role' do
      role.add_role(new_role)
      expect(role.to_string).to eq "#{role.name} < #{new_role.name}"
    end

    it 'when many role' do
      first_role = described_class.new('first_role')
      second_role = described_class.new('second_role')
      role.add_role(first_role)
      role.add_role(second_role)
      expect(role.to_string).to eq "#{role.name} < (#{first_role.name}, #{second_role.name})"
    end
  end
end
