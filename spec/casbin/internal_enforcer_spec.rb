# frozen_string_literal: true

require 'casbin/internal_enforcer'

describe Casbin::InternalEnforcer do
  # If we define these methods, this class can be removed
  let(:test_adapter_class) do
    Class.new(Casbin::Persist::Adapter) do
      def add_policies; end

      def update_policy; end

      def update_policies; end

      def remove_policies; end
    end
  end

  let(:model) { Casbin::Model::Model.new }
  let(:adapter) { test_adapter_class.new }
  let(:enforcer) { described_class.new model, adapter }
  let(:watcher) { double 'watcher' }

  let(:rule1) { %w[admin domain1 data1 read] }
  let(:rule2) { %w[admin domain1 data2 write] }

  let(:model_result) { true }
  let(:adapter_result) { true }

  before do
    %i[print_model print_policy clear_policy build_role_links].each do |meth|
      allow(model).to receive(meth)
    end
  end

  shared_examples 'properly handle method call' do
    # InternalEnforcer class has only protected methods, so we use `send`
    subject { enforcer.send method_name, *method_args }

    before { expect(model).to receive(method_name).with(*method_args).and_return model_result }

    context 'when model returns false' do
      let(:model_result) { false }

      it { is_expected.to be_falsey }
    end

    context 'without adapter' do
      let(:adapter) { nil }

      it { is_expected.to be_truthy }
    end

    context 'without autosave' do
      before do
        enforcer.auto_save = false
        expect(adapter).not_to receive method_name
      end

      it { is_expected.to be_truthy }
    end

    context 'with autosave' do
      before { expect(adapter).to receive(method_name).with(*method_args).and_return adapter_result }

      it { is_expected.to be_truthy }

      context 'when adapter returns false' do
        let(:adapter_result) { false }

        it { is_expected.to be_falsey }
      end

      context 'with watcher' do
        before do
          enforcer.watcher = watcher
          expect(watcher).to receive :update
        end

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#add_policy' do
    let(:method_name) { :add_policy }
    let(:method_args) { ['p', 'p', rule1] }

    it_behaves_like 'properly handle method call'
  end

  describe '#add_policies' do
    let(:method_name) { :add_policies }
    let(:method_args) { ['p', 'p', [rule1, rule2]] }

    it_behaves_like 'properly handle method call'
  end

  describe '#update_policy' do
    let(:method_name) { :update_policy }
    let(:method_args) { ['p', 'p', rule1, rule2] }

    it_behaves_like 'properly handle method call'
  end

  describe '#update_policies' do
    let(:method_name) { :update_policy }
    let(:method_args) { ['p', 'p', [rule1, rule2], [rule3, rule4]] }

    let(:rule3) { %w[admin2 domain1 data1 read] }
    let(:rule4) { %w[admin2 domain1 data2 read] }

    it_behaves_like 'properly handle method call'
  end

  describe '#remove_policy' do
    let(:method_name) { :remove_policy }
    let(:method_args) { ['p', 'p', rule1] }

    it_behaves_like 'properly handle method call'
  end

  describe '#remove_policies' do
    let(:method_name) { :remove_policies }
    let(:method_args) { ['p', 'p', [rule1, rule2]] }

    it_behaves_like 'properly handle method call'
  end

  describe '#remove_filtered_policy' do
    let(:method_name) { :remove_filtered_policy }
    let(:method_args) { ['p', 'p', 1, 'domain1', 'data1'] }

    it_behaves_like 'properly handle method call'
  end
end
