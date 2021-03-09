# frozen_string_literal: true

require 'casbin/config/config'

describe Casbin::Config::Config do
  let(:path) { File.expand_path('test.ini', __dir__) }
  let(:config) { described_class.new_config(path) }

  describe '#new_config_from_text' do
    let(:config) { described_class.new_config_from_text(text) }
    let(:text) do
      text = nil
      File.open(path, 'r:UTF-8') do |f|
        text = f.readlines.join
      end

      text
    end

    it 'reads config from text' do
      expect(config.get('debug')).to eq 'true'
      expect(config.get('redis::redis.key')).to eq 'push1,push2'
      expect(config.get('math::math.i64')).to eq '64'
      expect(config.get('other::name')).to eq 'ATC自动化测试^-^&($#……#'
      expect(config.get('multi1::name')).to eq 'r.sub==p.sub && r.obj==p.obj'
    end
  end

  describe '#get' do
    it 'default::key' do
      expect(config.get('debug')).to eq 'true'
      expect(config.get('url')).to eq 'act.wiki'
    end

    it 'redis::key' do
      expect(config.get('redis::redis.key')).to eq 'push1,push2'
      expect(config.get('mysql::mysql.dev.host')).to eq '127.0.0.1'
      expect(config.get('mysql::mysql.master.host')).to eq '10.0.0.1'
    end

    it 'math::key test' do
      expect(config.get('math::math.i64')).to eq '64'
      expect(config.get('math::math.f64')).to eq '64.1'
    end

    it 'other::key test' do
      expect(config.get('other::name')).to eq 'ATC自动化测试^-^&($#……#'
      expect(config.get('other::key1')).to eq 'test key'
    end

    it 'multi line' do
      expect(config.get('multi1::name')).to eq 'r.sub==p.sub && r.obj==p.obj'
      expect(config.get('multi2::name')).to eq 'r.sub==p.sub && r.obj==p.obj'
      expect(config.get('multi3::name')).to eq 'r.sub==p.sub && r.obj==p.obj'
      expect(config.get('multi4::name')).to eq ''
      expect(config.get('multi5::name')).to eq 'r.sub==p.sub && r.obj==p.obj'
    end
  end

  describe '#set' do
    it 'set other::key1' do
      config.set('other::key1', 'new test key')
      expect(config.get('other::key1')).to eq 'new test key'
    end
  end
end
