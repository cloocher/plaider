$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'simplecov'
require 'coveralls'

Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'webmock/test_unit'
require 'test/unit'
require 'plaider'

WebMock.disable_net_connect!(allow: 'coveralls.io')

def stub_delete(path)
  stub_request(:delete, Plaider::Client::DEV_BASE_URL + path)
end

def stub_get(path)
  stub_request(:get, Plaider::Client::DEV_BASE_URL + path)
end

def stub_post(path)
  stub_request(:post, Plaider::Client::DEV_BASE_URL + path)
end

def stub_put(path)
  stub_request(:put, Plaider::Client::DEV_BASE_URL + path)
end

def stub_patch(path)
  stub_request(:patch, Plaider::Client::DEV_BASE_URL + path)
end

def fixture_path
  File.expand_path('../fixtures', __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
