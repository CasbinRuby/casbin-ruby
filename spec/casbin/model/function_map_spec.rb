# frozen_string_literal: true

require 'casbin/model/function_map'
require 'casbin/util/builtin_operators'

describe Casbin::Model::FunctionMap do
  describe '#load_function_map' do
    let(:fm) { described_class.load_function_map.fm }
    let(:args) { ['abc'] }

    it 'returns function map' do
      {
        'keyMatch' => :key_match_func,
        'keyMatch2' => :key_match2_func,
        'regexMatch' => :regex_match_func,
        'ipMatch' => :ip_match_func,
        'globMatch' => :glob_match_func
      }.each do |key, meth|
        f = fm[key]
        expect(f).to be_a Proc
        expect(f).to be_lambda

        expect(Casbin::Util::BuiltinOperators).to receive(meth).with(*args)
        f.call(*args)
      end
    end
  end
end
