# frozen_string_literal: true

require 'casbin/model/model'
require 'support/examples'

describe Casbin::Model::Model do
  include Examples

  let(:model) { described_class.new }
  let(:base_config) { get_examples('basic_model.conf') }
  let(:rbac_config) { get_examples('rbac_model.conf') }
  let(:with_domains_config) { get_examples('rbac_with_domains_model.conf') }

  it '#get_policy' do
    model.load_model(base_config)
    rule = %w[admin domain1 data1 read]
    model.add_policy('p', 'p', rule)

    expect(model.get_policy('p', 'p') == [rule]).to be_truthy
  end

  it '#has_policy' do
    model.load_model(base_config)
    rule = %w[admin domain1 data1 read]
    model.add_policy('p', 'p', rule)

    expect(model.has_policy('p', 'p', rule)).to be_truthy
  end

  it '#add_policy' do
    model.load_model(base_config)
    rule = %w[admin domain1 data1 read]

    expect(model.has_policy('p', 'p', rule)).to be_falsey

    model.add_policy('p', 'p', rule)
    expect(model.has_policy('p', 'p', rule)).to be_truthy
  end

  it '#add_role_policy' do
    model.load_model(rbac_config)
    p_rule1 = %w[alice data1 read]
    model.add_policy('p', 'p', p_rule1)
    expect(model.has_policy('p', 'p', p_rule1)).to be_truthy

    p_rule2 = %w[data2_admin data2 read]
    model.add_policy('p', 'p', p_rule2)
    expect(model.has_policy('p', 'p', p_rule2)).to be_truthy

    g_rule = %w[alice data2_admin]
    model.add_policy('g', 'g', g_rule)
    expect(model.get_policy('p', 'p') == [p_rule1, p_rule2]).to be_truthy
    expect(model.get_policy('g', 'g') == [g_rule]).to be_truthy
  end

  it '#remove_policy' do
    model.load_model(base_config)
    rule = %w[admin domain1 data1 read]
    model.add_policy('p', 'p', rule)
    expect(model.has_policy('p', 'p', rule)).to be_truthy

    model.remove_policy('p', 'p', rule)
    expect(model.has_policy('p', 'p', rule)).to be_falsey
    expect(model.remove_policy('p', 'p', rule)).to be_falsey
  end

  it '#remove_filtered_policy' do
    model.load_model(with_domains_config)
    rule = %w[admin domain1 data1 read]
    model.add_policy('p', 'p', rule)

    res = model.remove_filtered_policy('p', 'p', 1, 'domain1', 'data1')
    expect(res).to be_truthy

    res = model.remove_filtered_policy('p', 'p', 1, 'domain1', 'data1')
    expect(res).to be_falsey
  end
end
