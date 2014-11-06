require 'test_helper'

class PlaiderTest < Test::Unit::TestCase
  def setup
    Plaider.configure do |config|
      config.client_id = 'client_id'
      config.secret = 'secret'
    end
  end

  def test_configure
    configurable = Plaider.configure do |config|
      config.client_id = 'client_id'
      config.secret = 'secret'
      config.access_token = 'access_token'
      config.open_timeout = 5
      config.read_timeout = 30
      config.verbose = true
      config.environment = 'development'
    end
    assert_equal 'client_id', configurable.instance_variable_get(:'@client_id')
    assert_equal 'secret', configurable.instance_variable_get(:'@secret')
    assert_equal 'access_token', configurable.instance_variable_get(:'@access_token')
    assert_equal 'development', configurable.instance_variable_get(:'@environment')
    assert_equal 5, configurable.instance_variable_get(:'@open_timeout')
    assert_equal 30, configurable.instance_variable_get(:'@read_timeout')
    assert_equal true, configurable.instance_variable_get(:'@verbose')
  end

  def test_scope
    client1 = Plaider.scope('1')
    assert_true client1.is_a?(Plaider::Client)
    assert_equal 'client_id', client1.instance_variable_get(:'@client_id')
    assert_equal 'secret', client1.instance_variable_get(:'@secret')
    client2 = Plaider.client
    assert_equal client1, client2
    client3 = Plaider.scope('1')
    assert_equal client1, client3
    client4 = Plaider.scope('2')
    assert_not_equal client1, client4
  end

  def test_static_call
    stub_get('/institutions').to_return(body: fixture('institutions.json'))
    response = Plaider.institutions
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal result.size, 10
    assert_equal result[0][:id], '5301a9d704977c52b60000db'
    assert_equal result[0][:type], 'amex'
    assert_equal result[0][:name], 'American Express'
  end
end
