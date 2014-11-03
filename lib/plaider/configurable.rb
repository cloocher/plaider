module Plaider
  module Configurable

    KEYS = [:client_id, :secret, :access_token, :open_timeout, :read_timeout, :verbose]

    attr_writer *KEYS

    def configure
      yield self
      self
    end

    private

    def options
      Plaider::Configurable::KEYS.inject({}) { |hash, key| hash[key] = instance_variable_get(:"@#{key}"); hash }
    end

  end
end
