# frozen_string_literal: true

RSpec.shared_context 'with policy files' do
  def policy_file(path)
    File.expand_path("files/policies/#{path}", __dir__)
  end

  let(:basic_policy_file) { policy_file('basic') }
  let(:rbac_policy_file) { policy_file('rbac') }
  let(:rbac_with_domains_policy_file) { policy_file('rbac_with_domains') }
end
