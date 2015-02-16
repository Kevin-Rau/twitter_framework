require 'bundler/setup'

require_relative 'Logging'
require_relative 'Params'
require_relative 'Properties'
require_relative 'Rates'

require 'json'
require 'simple_oauth'
require 'time'
require 'typhoeus'

class TwitterRequest

  include TwitterLog
  include TwitterParams
  include TwitterProperties
  include TwitterRates

  attr_reader :data, :log, :params, :props

  def initialize(args)
    @params   = args.fetch(:params)
    @data     = args.fetch(:data)
    @log      = args[:log] || default_logger
    @props    = load_props(@data[:props])
  end

  def url
    raise NotImplementedError, "No URL Specified for the Request"
  end

  def request_name
    raise NotImplementedError, "Request Name Not Specified"
  end

  def twitter_endpoint
    raise NotImplementedError, "Twitter Endpoint Not Specified"
  end

  def success(response)
    raise NotImplementedError, "Success Handler Not Specified"
  end

  def error(response)
    puts "FAILURE      : #{Time.now}"
    puts "Response Code: #{response.code}"
    puts "Response Info: #{response.status_message}"
    raise RuntimeError, "TwitterRequest Failed: #{response.code}"
  end

  def authorization
    header = SimpleOAuth::Header.new("GET", url, escaped_params, props)
    { 'Authorization' => header.to_s }
  end

  def options
    options = {}
    options[:method]  = :get
    options[:headers] = authorization

    request_params = {}
    escaped_params.keys.each do |key|
      request_params[key] = escaped_params[key] if include_param?(key)
    end

    options[:params]  = request_params
    options
  end

  def make_request
    check_rates
    request = Typhoeus::Request.new(url, options)
    log.info("REQUESTING: #{request.base_url}?#{display_params}")
    response = request.run
    @rate_count = @rate_count - 1
    response
  end

  def collect
    response = make_request
    if response.code == 200
      success(response) do |data|
        yield data
      end
    else
      error(response)
    end
  end

  public    :collect
  protected :error,         :make_request,     :request_name
  protected :success,       :twitter_endpoint, :url
  private   :authorization, :options

end