# frozen_string_literal: true

require 'casbin/util/builtin_operators'

describe Casbin::Util::BuiltinOperators do
  it '.key_match_func' do
    expect(described_class.key_match_func('/foo', '/foo')).to be_truthy
    expect(described_class.key_match_func('/foo', '/foo*')).to be_truthy
    expect(described_class.key_match_func('/foo', '/foo/*')).to be_falsey
    expect(described_class.key_match_func('/foo/bar', '/foo')).to be_falsey
    expect(described_class.key_match_func('/foo/bar', '/foo*')).to be_truthy
    expect(described_class.key_match_func('/foo/bar', '/foo/*')).to be_truthy
    expect(described_class.key_match_func('/foobar', '/foo')).to be_falsey
    expect(described_class.key_match_func('/foobar', '/foo*')).to be_truthy
    expect(described_class.key_match_func('/foobar', '/foo/*')).to be_falsey
  end

  it '.key_match2_func' do
    expect(described_class.key_match2_func('/foo', '/foo')).to be_truthy
    expect(described_class.key_match2_func('/foo', '/foo*')).to be_truthy
    expect(described_class.key_match2_func('/foo', '/foo/*')).to be_falsey
    expect(described_class.key_match2_func('/foo/bar', '/foo')).to be_falsey
    expect(described_class.key_match2_func('/foo/bar', '/foo*')).to be_falsey # different with key_match_func.
    expect(described_class.key_match2_func('/foo/bar', '/foo/*')).to be_truthy
    expect(described_class.key_match2_func('/foobar', '/foo')).to be_falsey
    expect(described_class.key_match2_func('/foobar', '/foo*')).to be_falsey # different with key_match_func.
    expect(described_class.key_match2_func('/foobar', '/foo/*')).to be_falsey

    expect(described_class.key_match2_func('/', '/:resource')).to be_falsey
    expect(described_class.key_match2_func('/resource1', '/:resource')).to be_truthy
    expect(described_class.key_match2_func('/myid', '/:id/using/:resId')).to be_falsey
    expect(described_class.key_match2_func('/myid/using/myresid', '/:id/using/:resId')).to be_truthy

    expect(described_class.key_match2_func('/proxy/myid', '/proxy/:id/*')).to be_falsey
    expect(described_class.key_match2_func('/proxy/myid/', '/proxy/:id/*')).to be_truthy
    expect(described_class.key_match2_func('/proxy/myid/res', '/proxy/:id/*')).to be_truthy
    expect(described_class.key_match2_func('/proxy/myid/res/res2', '/proxy/:id/*')).to be_truthy
    expect(described_class.key_match2_func('/proxy/myid/res/res2/res3', '/proxy/:id/*')).to be_truthy
    expect(described_class.key_match2_func('/proxy/', '/proxy/:id/*')).to be_falsey

    expect(described_class.key_match2_func('/alice', '/:id')).to be_truthy
    expect(described_class.key_match2_func('/alice/all', '/:id/all')).to be_truthy
    expect(described_class.key_match2_func('/alice', '/:id/all')).to be_falsey
    expect(described_class.key_match2_func('/alice/all', '/:id')).to be_falsey

    expect(described_class.key_match2_func('/alice/all', '/:/all')).to be_falsey
  end

  it '.key_match3_func' do
    # .key_match3_func is similar with .key_match2_func, except using "/proxy/{id}" instead of "/proxy/:id".
    expect(described_class.key_match3_func('/foo', '/foo')).to be_truthy
    expect(described_class.key_match3_func('/foo', '/foo*')).to be_truthy
    expect(described_class.key_match3_func('/foo', '/foo/*')).to be_falsey
    expect(described_class.key_match3_func('/foo/bar', '/foo')).to be_falsey
    expect(described_class.key_match3_func('/foo/bar', '/foo*')).to be_falsey
    expect(described_class.key_match3_func('/foo/bar', '/foo/*')).to be_truthy
    expect(described_class.key_match3_func('/foobar', '/foo')).to be_falsey
    expect(described_class.key_match3_func('/foobar', '/foo*')).to be_falsey
    expect(described_class.key_match3_func('/foobar', '/foo/*')).to be_falsey

    expect(described_class.key_match3_func('/', '/{resource}')).to be_falsey
    expect(described_class.key_match3_func('/resource1', '/{resource}')).to be_truthy
    expect(described_class.key_match3_func('/myid', '/{id}/using/{resId}')).to be_falsey
    expect(described_class.key_match3_func('/myid/using/myresid', '/{id}/using/{resId}')).to be_truthy

    expect(described_class.key_match3_func('/proxy/myid', '/proxy/{id}/*')).to be_falsey
    expect(described_class.key_match3_func('/proxy/myid/', '/proxy/{id}/*')).to be_truthy
    expect(described_class.key_match3_func('/proxy/myid/res', '/proxy/{id}/*')).to be_truthy
    expect(described_class.key_match3_func('/proxy/myid/res/res2', '/proxy/{id}/*')).to be_truthy
    expect(described_class.key_match3_func('/proxy/myid/res/res2/res3', '/proxy/{id}/*')).to be_truthy
    expect(described_class.key_match3_func('/proxy/', '/proxy/{id}/*')).to be_falsey

    expect(described_class.key_match3_func('/myid/using/myresid', '/{id/using/{resId}')).to be_falsey
  end

  it '.regex_match_func' do
    expect(described_class.regex_match_func('/topic/create', '/topic/create')).to be_truthy
    expect(described_class.regex_match_func('/topic/create/123', '/topic/create')).to be_truthy
    expect(described_class.regex_match_func('/topic/delete', '/topic/create')).to be_falsey
    expect(described_class.regex_match_func('/topic/edit', '/topic/edit/[0-9]+')).to be_falsey
    expect(described_class.regex_match_func('/topic/edit/123', '/topic/edit/[0-9]+')).to be_truthy
    expect(described_class.regex_match_func('/topic/edit/abc', '/topic/edit/[0-9]+')).to be_falsey
    expect(described_class.regex_match_func('/foo/delete/123', '/topic/delete/[0-9]+')).to be_falsey
    expect(described_class.regex_match_func('/topic/delete/0', '/topic/delete/[0-9]+')).to be_truthy
    expect(described_class.regex_match_func('/topic/edit/123s', '/topic/delete/[0-9]+')).to be_falsey
  end

  it '.glob_match_func' do
    expect(described_class.glob_match_func('/foo', '/foo')).to be_truthy
    expect(described_class.glob_match_func('/foo', '/foo*')).to be_truthy
    expect(described_class.glob_match_func('/foo', '/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '/foo')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '/foo*')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '/foo/*')).to be_truthy
    expect(described_class.glob_match_func('/foobar', '/foo')).to be_falsey
    expect(described_class.glob_match_func('/foobar', '/foo*')).to be_truthy
    expect(described_class.glob_match_func('/foobar', '/foo/*')).to be_falsey

    expect(described_class.glob_match_func('/foo', '*/foo')).to be_truthy
    expect(described_class.glob_match_func('/foo', '*/foo*')).to be_truthy
    expect(described_class.glob_match_func('/foo', '*/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/foo/bar', '*/foo/*')).to be_truthy
    expect(described_class.glob_match_func('/foobar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/foobar', '*/foo*')).to be_truthy
    expect(described_class.glob_match_func('/foobar', '*/foo/*')).to be_falsey

    expect(described_class.glob_match_func('/prefix/foo', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foo', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foo', '*/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foo/bar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foo/bar', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foo/bar', '*/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foobar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foobar', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/foobar', '*/foo/*')).to be_falsey

    expect(described_class.glob_match_func('/prefix/subprefix/foo', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foo', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foo', '*/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foo/bar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foo/bar', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foo/bar', '*/foo/*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foobar', '*/foo')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foobar', '*/foo*')).to be_falsey
    expect(described_class.glob_match_func('/prefix/subprefix/foobar', '*/foo/*')).to be_falsey
  end

  it '.ip_match_func' do
    expect(described_class.ip_match_func('192.168.2.123', '192.168.2.0/24')).to be_truthy
    expect(described_class.ip_match_func('192.168.2.123', '192.168.3.0/24')).to be_falsey
    expect(described_class.ip_match_func('192.168.2.123', '192.168.2.0/16')).to be_truthy
    expect(described_class.ip_match_func('192.168.2.123', '192.168.2.123')).to be_truthy
    expect(described_class.ip_match_func('192.168.2.123', '192.168.2.123/32')).to be_truthy
    expect(described_class.ip_match_func('10.0.0.11', '10.0.0.0/8')).to be_truthy
    expect(described_class.ip_match_func('11.0.0.123', '10.0.0.0/8')).to be_falsey
  end
end
