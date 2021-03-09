# frozen_string_literal: true

RSpec.shared_context 'with model configs' do
  def model_config(path)
    File.expand_path("files/models/#{path}", __dir__)
  end

  let(:basic_config) { model_config('basic.conf') }
  let(:rbac_config) { model_config('rbac.conf') }
  let(:rbac_with_domains_config) { model_config('rbac_with_domains.conf') }
end
