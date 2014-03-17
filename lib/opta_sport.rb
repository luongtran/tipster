require 'active_support/configurable'
require 'open-uri'
require 'nokogiri'

module OptaSport
  API_ROOT_URL = 'http://api.core.optasports.com'

  AVAILABLE_SPORTS = [
      SOCCER = 'soccer',
      BASEBALL = 'baseball',
      BASKETBALL = 'basketball',
      HANDBALL = 'handball',
      HOCKEY = 'hockey',
      TENNIS = 'tennis',
      FOOTBALL_US = 'american_football'
  ]
  AVAILABLE_FUNCTIONS = %w(get_areas get_matches get_compettions get_matches_live get_seasons get_teams)

  #SPORT_FUNCTIONS_MAP = {
  #    SOCCER => %w(get_areas get_matches get_compettions get_matches_live get_seasons get_teams),
  #    BASEBALL => %w(),
  #    BASKETBALL => %w(),
  #    HANDBALL => %w(),
  #    HOCKEY => %w(),
  #    TENNIS => %w(),
  #    FOOTBALL_US => %w(),
  #}

  def self.configure(&block)
    yield @config ||= OptaSport::Configuration.new
  end

  def self.available_sprorts
    %w(soccer baseball basketball handball hockey rugby tennis)
  end

  def self.available_functions

  end

  def self.config
    @config
  end

  def self.authenticate_params
    "&username=#{self.config.username}&authkey=#{self.config.authkey}"
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :username
    config_accessor :authkey
  end

  class Fetcher
    attr_accessor :sport, :function, :lang, :start_dt, :end_dt, :url

    def self.url_for(fetcher)
      u = API_ROOT_URL
      u << "/#{fetcher.sport}"
      u << "/#{fetcher.function}?"
      # After all, append authoriation info
      u << OptaSport.authenticate_params
    end

    def initialize(sport, options)
      if OptaSport.available_sprorts.exclude? sport
        raise "The given sport is not avaiable. Please use one of the following #{OptaSport.available_sprorts.join(' ')}"
      else
        default_options = {
            lang: :en,
            id: '',
            type: ''
        }
        options = default_options.merge options
        @sport = sport
        @function = options[:function]
        @lang = options[:lang]
      end
      self
    end

    def go!
      Nokogiri::XML(open(self.class.url_for(self)))
    end
  end

  class MatchesFetcher
    attr_accessor :id, :type
  end

  class Result
  end

  def self.get_football_areas
    fetcher = Fetcher.new(
        SOCCER,
        function: 'get_areas'
    )
    xml_result = fetcher.go!
    nodes = xml_result.xpath('//area')
    areas = []
    nodes.each do |area|
      areas << {
          name: area['name'],
          country_code: area['countrycode'],
          uid: area['area_id'],
          parent_id: area.parent['area_id']
      }
    end
    areas
  end
end