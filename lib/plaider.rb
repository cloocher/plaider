require 'plaider/version'
require 'plaider/configurable'
require 'plaider/client'

module Plaider
  class << self
    include Plaider::Configurable

    def scope(access_token)
      if !defined?(@access_token) || @access_token != access_token
        @access_token = access_token
        @client = Plaider::Client.new(options.merge({access_token: access_token}))
      end
      @client
    end

    def client
      @client ||= Plaider::Client.new(options)
    end

    private

    def method_missing(method_name, *args, &block)
      return super unless client.respond_to?(method_name)
      client.send(method_name, *args, &block)
    end

  end
end
