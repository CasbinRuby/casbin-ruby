# frozen_string_literal: true

require 'casbin-ruby/util/thread_lock'

describe ThreadLock do
  it '#lock? with no thread' do
    expect(described_class).not_to be_lock
  end

  it '#lock? with thread' do
    described_class.thread = Thread.new { loop }
    expect(described_class).to be_lock
    described_class.thread.exit
    sleep 0.001 # waiting exit
    expect(described_class).not_to be_lock
  end
end
