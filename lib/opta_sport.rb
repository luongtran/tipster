require 'active_support/configurable'
require 'opta_sport/error'
require 'opta_sport/fetcher'
module OptaSport
  AVAILABLE_SPORT = %w(soccer basketball)

  API_ROOT_URL = 'http://api.core.optasports.com'

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :username
    config_accessor :authkey
  end

  class << self
    def configure(&block)
      yield @config ||= OptaSport::Configuration.new
    end

    def config
      @config
    end

    def authenticate_params
      #"&username=#{config.username}&authkey=#{config.authkey}"
      "&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3"
    end
  end
end