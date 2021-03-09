# frozen_string_literal: true

require 'casbin/model/model'
require 'casbin/rbac/default_role_manager/role_manager'
require 'support/model_configs_context'

describe Casbin::Model::Model do
  include_context 'with model configs'

  let(:model) { described_class.new }

  let(:rule1) { %w[admin data1 read] }
  let(:rule2) { %w[admin data2 write] }

  describe '#load_model_from_text' do
    let(:text) do
      text = nil
      File.open(basic_config, 'r:UTF-8') do |f|
        text = f.readlines.join
      end

      text
    end

    it 'loads model' do
      model.load_model_from_text(text)
      model.add_policy('p', 'p', rule1)

      expect(model.get_policy('p', 'p') == [rule1]).to be_truthy
    end
  end

  describe '#build_role_links' do
    let(:rm) { Casbin::Rbac::DefaultRoleManager::RoleManager.new(1) }

    context 'without roles' do
      before { model.load_model(basic_config) }

      it { expect(model.build_role_links(rm)).to be_nil }
    end

    context 'with roles' do
      before do
        model.load_model(rbac_config)
        model.add_policy('g', 'g', %w[alice admin])
      end

      it 'builds role links' do
        model.model['g'].each_value do |ast|
          expect(ast).to receive(:build_role_links).with(rm)
        end

        model.build_role_links(rm)
      end
    end
  end

  describe 'logging' do
    let(:model) { described_class.new logger: mock_logger }
    let(:mock_logger) { instance_double Logger }
    let(:log) { [] }

    before do
      allow(mock_logger).to receive(:info) { |msg| log.push msg }

      model.load_model(rbac_config)
    end

    describe '#print_model' do
      let(:expected) do
        [
          'Model:',
          'r.r: sub, obj, act',
          'p.p: sub, obj, act',
          'g.g: _, _',
          'e.e: some(where (p_eft == allow))',
          'm.m: g(r_sub, p_sub) && r_obj == p_obj && r_act == p_act'
        ]
      end

      it 'prints model contents to log' do
        model.print_model
        expect(log).to eq(expected)
      end
    end

    describe '#print_policy' do
      let(:expected) do
        [
          'Policy:',
          'p : sub, obj, act : []',
          'g : _, _ : []'
        ]
      end

      it 'prints policy contents to log' do
        model.print_policy
        expect(log).to eq(expected)
      end
    end
  end

  describe '#clear_policy' do
    before do
      model.load_model(rbac_config)
      p_rule1 = %w[alice data1 read]
      model.add_policy('p', 'p', p_rule1)
      p_rule2 = %w[data2_admin data2 read]
      model.add_policy('p', 'p', p_rule2)
      g_rule = %w[alice data2_admin]
      model.add_policy('g', 'g', g_rule)
    end

    it 'clears policies' do
      model.clear_policy

      expect(model.get_policy('p', 'p')).to be_empty
      expect(model.get_policy('g', 'g')).to be_empty
    end
  end

  it '#get_policy' do
    model.load_model(basic_config)
    model.add_policy('p', 'p', rule1)

    expect(model.get_policy('p', 'p') == [rule1]).to be_truthy
  end

  it '#has_policy' do
    model.load_model(basic_config)
    model.add_policy('p', 'p', rule1)

    expect(model.has_policy('p', 'p', rule1)).to be_truthy
  end

  describe '#add_policy' do
    it 'adds policy' do
      model.load_model(basic_config)
      expect(model.has_policy('p', 'p', rule1)).to be_falsey

      expect(model.add_policy('p', 'p', rule1)).to be_truthy

      expect(model.has_policy('p', 'p', rule1)).to be_truthy
    end

    it 'adds role policy' do
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
  end

  describe '#add_policies' do
    subject { model.add_policies('p', 'p', [rule1, rule2]) }

    before { model.load_model(basic_config) }

    it 'adds policies' do
      expect(model.has_policy('p', 'p', rule1)).to be_falsey
      expect(model.has_policy('p', 'p', rule2)).to be_falsey

      expect(subject).to be_truthy

      expect(model.has_policy('p', 'p', rule1)).to be_truthy
      expect(model.has_policy('p', 'p', rule2)).to be_truthy
    end

    context 'when some of policies already was added' do
      before { model.add_policy('p', 'p', rule2) }

      it 'does not add policies' do
        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy

        expect(subject).to be_falsey

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy
      end
    end
  end

  describe '#update_policy' do
    subject { model.update_policy('p', 'p', rule1, rule2) }

    before { model.load_model(basic_config) }

    context 'without old policy' do
      before { model.add_policy('p', 'p', rule2) }

      it 'does nothing' do
        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy

        expect(subject).to be_falsey

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy
      end
    end

    context 'with old policy' do
      before { model.add_policy('p', 'p', rule1) }

      it 'updates policy' do
        expect(model.has_policy('p', 'p', rule1)).to be_truthy
        expect(model.has_policy('p', 'p', rule2)).to be_falsey

        expect(subject).to be_truthy

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy
      end
    end
  end

  describe '#update_policies' do
    subject { model.update_policies('p', 'p', [rule1, rule2], [rule3, rule4]) }

    let(:rule3) { %w[admin2 domain1 data1 read] }
    let(:rule4) { %w[admin2 domain1 data2 read] }

    before { model.load_model(basic_config) }

    context 'without some of old policies' do
      before { model.add_policy('p', 'p', rule2) }

      it 'does nothing' do
        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy

        expect(subject).to be_falsey

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_truthy
      end
    end

    context 'with all old policies' do
      before { model.add_policies('p', 'p', [rule1, rule2]) }

      it 'updates policy' do
        expect(model.has_policy('p', 'p', rule1)).to be_truthy
        expect(model.has_policy('p', 'p', rule2)).to be_truthy

        expect(subject).to be_truthy

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_falsey
        expect(model.has_policy('p', 'p', rule3)).to be_truthy
        expect(model.has_policy('p', 'p', rule4)).to be_truthy
      end
    end
  end

  describe '#remove_policy' do
    subject { model.remove_policy('p', 'p', rule1) }

    before { model.load_model(basic_config) }

    describe 'without removed policy' do
      it 'does nothing' do
        expect(model.has_policy('p', 'p', rule1)).to be_falsey

        expect(subject).to be_falsey
      end
    end

    describe 'with removed policy' do
      before { model.add_policy('p', 'p', rule1) }

      it 'removes policy' do
        expect(model.has_policy('p', 'p', rule1)).to be_truthy

        expect(subject).to be_truthy

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
      end
    end
  end

  describe '#remove_policies' do
    subject {  model.remove_policies('p', 'p', [rule1, rule2]) }

    before { model.load_model(basic_config) }

    describe 'without some of removed policies' do
      before { model.add_policy('p', 'p', rule1) }

      it 'does nothing' do
        expect(model.has_policy('p', 'p', rule1)).to be_truthy
        expect(model.has_policy('p', 'p', rule2)).to be_falsey

        expect(subject).to be_falsey

        expect(model.has_policy('p', 'p', rule1)).to be_truthy
        expect(model.has_policy('p', 'p', rule2)).to be_falsey
      end
    end

    describe 'with all of removed policies' do
      before { model.add_policies('p', 'p', [rule1, rule2]) }

      it 'removes policies' do
        expect(model.has_policy('p', 'p', rule1)).to be_truthy
        expect(model.has_policy('p', 'p', rule2)).to be_truthy

        expect(subject).to be_truthy

        expect(model.has_policy('p', 'p', rule1)).to be_falsey
        expect(model.has_policy('p', 'p', rule2)).to be_falsey
      end
    end
  end

  it '#remove_filtered_policy' do
    domain_rule = %w[admin domain1 data1 read]

    model.load_model(rbac_with_domains_config)
    model.add_policy('p', 'p', domain_rule)

    res = model.remove_filtered_policy('p', 'p', 1, 'domain1', 'data1')
    expect(res).to be_truthy

    res = model.remove_filtered_policy('p', 'p', 1, 'domain1', 'data1')
    expect(res).to be_falsey
  end
end
