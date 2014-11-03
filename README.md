# Plaider
[![Build Status](https://travis-ci.org/cloocher/plaider.png)](https://travis-ci.org/cloocher/plaider)
[![Coverage Status](https://coveralls.io/repos/cloocher/plaider/badge.png?branch=master)](https://coveralls.io/r/cloocher/plaider)
[![Gem Version](https://badge.fury.io/rb/plaider.png)](http://badge.fury.io/rb/plaider)

  Plaid API client

## Installation

Plaider is available through [Rubygems](http://rubygems.org/gems/plaider) and can be installed via:

```
$ gem install plaider
```

or add it to your Gemfile like this:

```
gem 'plaider'
```

## Start Guide

Register for [Plaid](https://plaid.com/account/signup).

## Usage

```ruby
require 'plaider'

# Plaider global configuration
Plaider.configure do |config|
  config.client_id = 'client id'
  config.secret = 'secret'
end

# alternatively, specify configuration options when instantiating an Aggcat::Client
client = Plaider::Client.new(
  client_id: 'client id',
  secret: 'secret',
  access_token: 'scope for all requests'
)

# create an scoped client by access_token
client = Aggcat.scope(access_token)

# you could use default scope (no access_token) for non-user specific calls
client = Aggcat.scope

# get all supported financial institutions
client.institutions

# get Chase Bank details
client.institution('5301a99504977c52b60000d0')

# add new financial account to aggregate from Chase
intitution_type = 'chase'
response = client.add_user(intitution_type, username, password, email)

# in case MFA is required
questions = response[:mfa]
answer = 'answer'
client.user_confirmation(answer)

# get already aggregated financial accounts and transactions for the scoped user
client.transactions

# get all account balances
client.balance

# filter transactions
start_date = Date.today - 30
end_date = Date.today # optional
pending = true # include pending transactions
client.transactions(account_id, start_date, end_date, pending)

# update user credentials
client.update_user(username, new_password)

# you can set scope inline for any request
Aggcat.scope(access_token).transactions

# delete user
client.delete_user
```

## Requirements

* Ruby 1.9.3 or higher

## Copyright
Copyright (c) 2014 Gene Drabkin.
See [LICENSE][] for details.

[license]: LICENSE.md
