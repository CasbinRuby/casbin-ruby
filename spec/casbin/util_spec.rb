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

  describe '#escape_assertion' do
    subject { described_class.escape_assertion(value) }

    context 'without attributes' do
      let(:value) { 'm = r.sub == p.sub && r.obj == p.obj && r.act == p.act' }

      it { is_expected.to eq 'm = r_sub == p_sub && r_obj == p_obj && r_act == p_act' }
    end

    context 'with attributes' do
      context 'with latin identifier' do
        let(:value) { 'm = r.sub.Chief == r.obj.Owner' }

        it { is_expected.to eq "m = r_sub['Chief'] == r_obj['Owner']" }
      end

      context 'with underscore' do
        let(:value) { 'm = r.sub == r.obj._Owner' }

        it { is_expected.to eq "m = r_sub == r_obj['_Owner']" }
      end

      context 'with unicode identifier' do
        let(:value) { 'm = r.sub == r.obj.Идентификатор1' }

        it { is_expected.to eq "m = r_sub == r_obj['Идентификатор1']" }
      end

      context 'with nested identifiers' do
        let(:value) { 'm = r.sub == r.obj.Owner.Position' }

        it { is_expected.to eq "m = r_sub == r_obj['Owner']['Position']" }
      end
    end
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

  describe '#replace_eval' do
    subject { described_class.replace_eval(expr, rules) }

    context 'with eval in the beginning' do
      let(:expr) { 'eval(a) && eval(b) && c' }
      let(:rules) { { 'a' => '1 + 1', 'b' => 'a + 1' } }

      it { is_expected.to eq '(1 + 1) && (a + 1) && c' }
    end

    context 'with eval in the end' do
      let(:expr) { 'a && eval(b) && eval(c)' }
      let(:rules) { { 'b' => '1', 'c' => '(a + 1) + c' } }

      it { is_expected.to eq 'a && (1) && ((a + 1) + c)' }
    end
  end

  it '.get_eval_value' do
    expect(described_class.get_eval_value('eval(a) && a && b && c')).to match_array(['a'])
    expect(described_class.get_eval_value('a && eval(a) && b && c')).to match_array(['a'])
    expect(described_class.get_eval_value('eval(a) && eval(b) && a && b && c')).to match_array(%w[a b])
    expect(described_class.get_eval_value('eval(p.sub_rule) || p.obj == r.obj && eval(p.domain_rule)'))
      .to match_array(%w[p.sub_rule p.domain_rule])
  end
end
