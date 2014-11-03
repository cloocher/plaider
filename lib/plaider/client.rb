module Plaider
  class Client

    BASE_URL = 'https://tartan.plaid.com'

    OPEN_TIMEOUT = 15
    READ_TIMEOUT = 120

    def initialize(options={})
      options[:open_timeout] ||= OPEN_TIMEOUT
      options[:read_timeout] ||= READ_TIMEOUT
      options[:verbose] ||= false
      Plaider::Configurable::KEYS.each do |key|
        instance_variable_set(:"@#{key}", !options[key].nil? ? options[key] : Plaider.instance_variable_get(:"@#{key}"))
      end
    end

    def institutions
      get('/institutions')
    end

    def institution(institution_id)
      validate(institution_id: institution_id)
      get("/institutions/#{institution_id}")
    end

    def categories
      get('/categories')
    end

    def category(category_id)
      validate(category_id: category_id)
      get("/categories/#{category_id}")
    end

    def entity(entity_id)
      validate(entity_id: entity_id)
      get("/entities/#{entity_id}")
    end

    def balance
      get('/balance')
    end

    def add_user(institution_type, username, password, email)
      validate(institution_type: institution_type, username: username, password: password, email: email)
      post('/connect', {type: institution_type, username: username, password: password, email: email})
    end

    def user_confirmation(mfa)
      validate(mfa: mfa)
      post('/connect/step', {mfa: mfa})
    end

    def transactions(account_id = nil, start_date = nil, end_date = nil, pending = false)
      body = {}
      body[:account_id] = account_id if account_id
      body[:gte] = account_id if start_date
      body[:lte] = account_id if end_date
      body[:pending] = account_id if pending
      post('/connect/get', body)
    end

    def update_user(username, password)
      validate(username: username, password: password)
      put('/connect', {username: username, password: password})
    end

    def delete_user
      delete('/connect')
    end

    protected

    def get(path)
      JSON.parse(Net::HTTP.get(URI.parse(BASE_URL + path)))
    end

    def post(path, body)
      JSON.parse(Net::HTTP.post_form(URI.parse(BASE_URL + path), body))
    end

    def put(path, body)
      http = Net::HTTP.new(BASE_URL)
      request = Net::HTTP::Post.new(path)
      request.set_form_data(body)
      JSON.parse(http.request(request))
    end

    def delete(path)
      http = Net::HTTP.new(BASE_URL)
      request = Net::HTTP::Delete.new(path)
      JSON.parse(http.request(request))
    end

    private

    def validate(args)
      args.each do |name, value|
        if value.nil? || value.to_s.empty?
          raise ArgumentError.new("#{name} is required")
        end
      end
    end
  end

end
