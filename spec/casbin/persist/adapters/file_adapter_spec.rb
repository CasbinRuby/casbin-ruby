# frozen_string_literal: true

require 'tempfile'

require 'casbin/model/model'
require 'casbin/persist/adapters/file_adapter'
require 'support/model_configs_context'
require 'support/policy_files_context'

describe Casbin::Persist::Adapters::FileAdapter do
  include_context 'with model configs'
  include_context 'with policy files'

  let(:adapter) { described_class.new path }
  let(:model) { Casbin::Model::Model.new }

  describe '#load_policy' do
    subject { adapter.load_policy model }

    before { model.load_model model_path }

    context 'with basic' do
      let(:model_path) { basic_config }
      let(:path) { basic_policy_file }

      let(:rule1) { %w[admin data1 read] }
      let(:rule2) { %w[admin data2 write] }

      it 'loads correct policies' do
        subject

        [rule1, rule2].each do |rule|
          expect(model.has_policy('p', 'p', rule)).to be_truthy
        end
      end
    end

    context 'with rbac' do
      let(:model_path) { rbac_config }
      let(:path) { rbac_policy_file }

      let(:p_rule1) { %w[diana data1 read] }
      let(:p_rule2) { %w[data_admin data2 read] }
      let(:g_rule) {  %w[diana data_admin] }

      it 'loads correct policies' do
        subject

        [p_rule1, p_rule2].each do |rule|
          expect(model.has_policy('p', 'p', rule)).to be_truthy
        end
        expect(model.has_policy('g', 'g', g_rule)).to be_truthy
      end
    end

    context 'with rbac_with_domains' do
      let(:model_path) { rbac_with_domains_config }
      let(:path) { rbac_with_domains_policy_file }

      let(:p_rule1) { %w[diana domain data read] }
      let(:p_rule2) { %w[data_admin other_domain data read] }
      let(:g_rule1) {  %w[alice data_admin] }
      let(:g_rule2) {  %w[diana data_admin] }

      it 'loads correct policies' do
        subject

        [p_rule1, p_rule2].each do |rule|
          expect(model.has_policy('p', 'p', rule)).to be_truthy
        end
        [g_rule1, g_rule2].each do |rule|
          expect(model.has_policy('g', 'g', rule)).to be_truthy
        end
      end
    end
  end

  describe '#save_policy' do
    subject { adapter.save_policy model }

    let(:file) { Tempfile.new 'policy' }
    let(:path) { file.path }

    shared_examples 'saves correct file' do
      it do
        subject
        expect(file.readlines).to eq(File.readlines(expected_file))
      end
    end

    before { model.load_model model_path }

    after do
      file.close
      file.unlink
    end

    context 'with basic' do
      let(:model_path) { basic_config }
      let(:expected_file) { basic_policy_file }

      let(:rule1) { %w[admin data1 read] }
      let(:rule2) { %w[admin data2 write] }

      before { model.add_policies 'p', 'p', [rule1, rule2] }

      it_behaves_like 'saves correct file'
    end

    context 'with rbac' do
      let(:model_path) { rbac_config }
      let(:expected_file) { rbac_policy_file }

      let(:p_rule1) { %w[diana data1 read] }
      let(:p_rule2) { %w[data_admin data2 read] }
      let(:g_rule) {  %w[diana data_admin] }

      before do
        model.add_policies 'p', 'p', [p_rule1, p_rule2]
        model.add_policy 'g', 'g', g_rule
      end

      it_behaves_like 'saves correct file'
    end

    context 'with rbac_with_domains' do
      let(:model_path) { rbac_with_domains_config }
      let(:expected_file) { rbac_with_domains_policy_file }

      let(:p_rule1) { %w[diana domain data read] }
      let(:p_rule2) { %w[data_admin other_domain data read] }
      let(:g_rule1) {  %w[alice data_admin] }
      let(:g_rule2) {  %w[diana data_admin] }

      before do
        model.add_policies 'p', 'p', [p_rule1, p_rule2]
        model.add_policies 'g', 'g', [g_rule1, g_rule2]
      end

      it_behaves_like 'saves correct file'
    end
  end
end
