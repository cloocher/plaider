require 'net/https'
require 'json'

module Plaider
  class Client

    DEV_BASE_URL = 'https://tartan.plaid.com'
    PROD_BASE_URL = 'https://api.plaid.com'

    DATE_FORMAT = '%Y-%m-%d'

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
      post('/balance')
    end

    def add_user(institution_type, username, password, email)
      validate(institution_type: institution_type, username: username, password: password, email: email)
      response = post('/connect', {type: institution_type, username: username, password: password, email: email, login_only: true})
      status_code = response[:status_code].to_i
      @access_token = response[:result][:access_token] if [200, 201].include?(status_code)
      response
    end

    def user_confirmation(mfa)
      validate(mfa: mfa)
      post('/connect/step', {mfa: mfa})
    end

    def transactions(account_id = nil, start_date = nil, end_date = nil, pending = false)
      params = {}
      params[:account_id] = account_id if account_id
      params[:gte] = format_date(start_date)
      params[:lte] = format_date(end_date)
      params[:pending] = pending
      post('/connect/get', params)
    end

    def update_user(username, password)
      validate(username: username, password: password)
      patch('/connect', {username: username, password: password})
    end

    def delete_user
      response = delete('/connect')
      @access_token = nil
      response
    end

    def access_token
      @access_token
    end

    protected

    def get(path)
      process(Net::HTTP::Get.new(path))
    end

    def post(path, params = {})
      request = Net::HTTP::Post.new(path)
      params.merge!(credentials)
      params.merge!(access_token: @access_token) if !!@access_token
      request.set_form_data(params)
      process(request)
    end

    def patch(path, params = {})
      request = Net::HTTP::Patch.new(path)
      params.merge!(credentials)
      params.merge!(access_token: @access_token) if !!@access_token
      request.set_form_data(params)
      process(request)
    end

    def delete(path)
      request = Net::HTTP::Delete.new(path)
      request.set_form_data(credentials.merge(access_token: @access_token)) if !!@access_token
      process(request)
    end

    private

    def validate(args)
      args.each do |name, value|
        if value.nil? || value.to_s.empty?
          raise ArgumentError.new("#{name} is required")
        end
      end
    end

    def credentials
      @credentials ||= {client_id: @client_id, secret: @secret}
    end

    def http
      unless defined?(@http)
        uri = URI.parse(@environment == 'production' ? PROD_BASE_URL : DEV_BASE_URL)
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @http.set_debug_output($stdout) if @verbose
      end
      @http
    end

    def process(request)
      response = http.request(request)
      {status_code: response.code, result: JSON.parse(response.body, {symbolize_names: true})}
    end

    def format_date(date)
      !!date ? date.strftime(DATE_FORMAT) : date
    end
  end

end
