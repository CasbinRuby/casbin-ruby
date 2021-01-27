# frozen_string_literal: true

require 'casbin/util'

describe Casbin::Util do
  it '.remove_comments' do
    expect(described_class.remove_comments('r.act == p.act # comments')).to eq 'r.act == p.act'
    expect(described_class.remove_comments('r.act == p.act#comments')).to eq 'r.act == p.act'
    expect(described_class.remove_comments('r.act == p.act###')).to eq 'r.act == p.act'
    expect(described_class.remove_comments('### comments')).to eq ''
    expect(described_class.remove_comments('r.act == p.act')).to eq 'r.act == p.act'
  end

  it '.escape_assertion' do
    expect(described_class.escape_assertion('m = r.sub == p.sub && r.obj == p.obj && r.act == p.act'))
      .to eq 'm = r_sub == p_sub && r_obj == p_obj && r_act == p_act'
  end

  it '.array_remove_duplicates' do
    expect(described_class.array_remove_duplicates(%w[data data1 data2 data1 data2 data3]))
      .to match_array(%w[data data1 data2 data3])
  end

  it '.array_to_string' do
    expect(described_class.array_to_string(%w[data data1 data2 data3])).to eq 'data, data1, data2, data3'
  end

  it '.params_to_string' do
    expect(described_class.params_to_string('data', 'data1', 'data2', 'data3')).to eq 'data, data1, data2, data3'
  end

  it '.has_eval' do
    expect(described_class.has_eval('eval() && a && b && c')).to be_truthy
    expect(described_class.has_eval('a && b && eval(c)')).to be_truthy
    expect(described_class.has_eval('eval) && a && b && c')).to be_falsey
    expect(described_class.has_eval('eval)( && a && b && c')).to be_falsey
    expect(described_class.has_eval('eval(c * (a + b)) && a && b && c')).to be_truthy
    expect(described_class.has_eval('xeval() && a && b && c')).to be_falsey
    expect(described_class.has_eval('eval(a) && eval(b) && a && b && c')).to be_truthy
  end

  it '.replace_eval' do
    expect(described_class.replace_eval('eval(a) && eval(b) && c', %w[a b])).to eq '(a) && (b) && c'
    expect(described_class.replace_eval('a && eval(b) && eval(c)', %w[b c])).to eq 'a && (b) && (c)'
  end

  it '.get_eval_value' do
    expect(described_class.get_eval_value('eval(a) && a && b && c')).to match_array(['a'])
    expect(described_class.get_eval_value('a && eval(a) && b && c')).to match_array(['a'])
    expect(described_class.get_eval_value('eval(a) && eval(b) && a && b && c')).to match_array(%w[a b])
    expect(described_class.get_eval_value('eval(p.sub_rule) || p.obj == r.obj && eval(p.domain_rule)'))
      .to match_array(%w[p.sub_rule p.domain_rule])
  end
end
