require 'test_helper'

class ClientTest < Test::Unit::TestCase
  def setup
    @client = Plaider::Client.new(
        {
            client_id: 'client_id',
            secret: 'secret',
            access_token: 'access_token'
        }
    )
  end

  def test_arguments
    assert_equal 'client_id', @client.instance_variable_get(:'@client_id')
    assert_equal 'secret', @client.instance_variable_get(:'@secret')
    assert_equal 'access_token', @client.instance_variable_get(:'@access_token')
  end

  def test_institutions
    stub_get('/institutions').to_return(body: fixture('institutions.json'))
    response = @client.institutions
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal result.size, 10
    assert_equal result[0][:id], '5301a9d704977c52b60000db'
    assert_equal result[0][:type], 'amex'
    assert_equal result[0][:name], 'American Express'
  end

  def test_institution
    institution_id = '5301a9d704977c52b60000db'
    stub_get("/institutions/#{institution_id}").to_return(body: fixture('institution.json'))
    response = @client.institution(institution_id)
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal institution_id, result[:id]
    assert_equal 'amex', result[:type]
    assert_equal 'American Express', result[:name]
  end

  def test_institution_with_bad_args
    [nil, ''].each do |arg|
      exception = assert_raise(ArgumentError) { @client.institution(arg) }
      assert_equal('institution_id is required', exception.message)
    end
  end

  def test_add_user
    stub_post('/connect').to_return(body: fixture('connect.json'))
    response = @client.add_user('institution_type', 'username', 'password', 'test@testemail.com')
    assert_not_nil response
    assert_not_nil '200', response[:status_code]
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:accounts]
    assert_equal 4, result[:accounts].size
    assert_equal 1203.42, result[:accounts][0][:balance][:available]
    assert_equal 1274.93, result[:accounts][0][:balance][:current]
    assert_equal 'fake_institution', result[:accounts][0][:institution_type]
    assert_equal 'depository', result[:accounts][0][:type]
    assert_not_nil result[:transactions]
    assert_equal 16, result[:transactions].size
  end

  def test_add_user_with_invalid_credencials
    stub_post('/connect').to_return(body: fixture('connect_invalid.json'))
    response = @client.add_user('institution_type', 'username', 'password', 'test@testemail.com')
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal 'invalid credentials', result[:message]
  end

  def test_add_user_with_mfa
    stub_post('/connect').to_return(status: 201, body: fixture('connect_mfa.json'))
    response = @client.add_user('institution_type', 'username', 'password', 'test@testemail.com')
    assert_not_nil response
    assert_not_nil '201', response[:status_code]
    result = response[:result]
    assert_not_nil result
    assert_equal 'You say tomato, I say...?', result[:mfa][0][:question]
  end

  def test_user_confirmation
    stub_post('/connect/step').to_return(body: fixture('connect.json'))
    response = @client.user_confirmation('tomato')
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:accounts]
    assert_equal 4, result[:accounts].size
    assert_equal 1203.42, result[:accounts][0][:balance][:available]
    assert_equal 1274.93, result[:accounts][0][:balance][:current]
    assert_equal 'fake_institution', result[:accounts][0][:institution_type]
    assert_equal 'depository', result[:accounts][0][:type]
    assert_not_nil result[:transactions]
    assert_equal 16, result[:transactions].size
  end

  def test_user_confirmation_with_invalid_answer
    stub_post('/connect/step').to_return(body: fixture('connect_mfa_invalid.json'))
    response = @client.user_confirmation('abc')
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal 'invalid mfa', result[:message]
  end

  def test_transactions
    stub_post('/connect/get').to_return(body: fixture('connect.json'))
    response = @client.transactions
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:accounts]
    assert_equal 4, result[:accounts].size
    assert_equal 1203.42, result[:accounts][0][:balance][:available]
    assert_equal 1274.93, result[:accounts][0][:balance][:current]
    assert_equal 'fake_institution', result[:accounts][0][:institution_type]
    assert_equal 'depository', result[:accounts][0][:type]
    assert_not_nil result[:transactions]
    assert_equal 16, result[:transactions].size
  end

  def test_transactions_valid_args
    stub_post('/connect/get').to_return(body: fixture('connect.json'))
    response = @client.transactions('123456789', Date.today - 30, Date.today, true)
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:accounts]
    assert_equal 4, result[:accounts].size
    assert_equal 1203.42, result[:accounts][0][:balance][:available]
    assert_equal 1274.93, result[:accounts][0][:balance][:current]
    assert_equal 'fake_institution', result[:accounts][0][:institution_type]
    assert_equal 'depository', result[:accounts][0][:type]
    assert_not_nil result[:transactions]
    assert_equal 16, result[:transactions].size
  end

  def test_update_user
    stub_patch('/connect').to_return(body: fixture('connect_mfa.json'))
    response = @client.update_user('username', 'password')
    assert_not_nil response
    assert_not_nil '201', response[:status_code]
    result = response[:result]
    assert_not_nil result
    assert_equal 'You say tomato, I say...?', result[:mfa][0][:question]
  end

  def test_delete_user
    stub_delete('/connect').to_return(body: fixture('delete_user.json'))
    response = @client.delete_user
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal 'Successfully removed from system', result[:message]
  end

  def test_balance
    stub_post('/balance').to_return(body: fixture('balance.json'))
    response = @client.balance
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:accounts]
    assert_equal 4, result[:accounts].size
    assert_equal 1203.42, result[:accounts][0][:balance][:available]
    assert_equal 1274.93, result[:accounts][0][:balance][:current]
    assert_equal 'fake_institution', result[:accounts][0][:institution_type]
    assert_equal 'depository', result[:accounts][0][:type]
  end

  def test_categories
    stub_get('/categories').to_return(body: fixture('categories.json'))
    response = @client.categories
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal 4, result.size
  end

  def test_category
    stub_get('/categories/52544965f71e87d007000008').to_return(body: fixture('category.json'))
    response = @client.category('52544965f71e87d007000008')
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_not_nil result[:mappings]
    assert_equal 3, result[:mappings].size
    assert_equal 'Arts and Entertainment', result[:hierarchy][0]
  end

  def test_entity
    stub_get('/entities/539c40548590c9d05eaec20a').to_return(body: fixture('entity.json'))
    response = @client.entity('539c40548590c9d05eaec20a')
    assert_not_nil response
    result = response[:result]
    assert_not_nil result
    assert_equal 'Apple Store', result[:name]
  end

end
