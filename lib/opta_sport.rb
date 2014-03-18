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

  class << self

    def configure(&block)
      yield @config ||= OptaSport::Configuration.new
    end

    def config
      @config
    end

    def authenticate_params
      "&username=#{self.config.username}&authkey=#{self.config.authkey}"
    end

    def sport_functions
      @@sport_functions ||= YAML.load_file(File.join(Rails.root, 'config', 'opta_sport_functions.yml'))
    end

    def required_params_for(sport, function)
      OptaSport.sport_functions[sport]['functions'][function.to_s]['required_params']
    end

    def optional_params_for(sport, function)
      OptaSport.sport_functions[sport]['functions'][function.to_s]['optional_params']
    end

    AVAILABLE_SPORTS.each do |sport|
      define_method sport.to_sym do
        return "#{self.name}::Fetcher::#{sport.capitalize}".constantize.new
      end
    end

    alias_method :football, :soccer

    def get_football_areas
      fetcher = Fetcher.new(
          SOCCER,
          function: 'get_areas'
      )
      xml_result = fetcher.go
      nodes = xml_result.xpath('//area')
      areas = []
      nodes.each do |area|
        areas << {
            area_id: area['area_id'],
            name: area['name'],
            country_code: area['countrycode'],
            parent_area_id: area.parent['area_id']
        }
      end
      areas
    end

    def get_football_matches
      fetcher = Fetcher.new(
          SOCCER,
          function: 'get_matches'
      )
      xml_result = fetcher.go
    end
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :username
    config_accessor :authkey
  end

  module Fetcher
    #SPORT_TYPE_TO_CLASS = {
    #    'soccer' => Soccer,
    #}
    class Base
      #include ActiveRecord::ReadonlyAttributes
      attr_accessor :function, :params, :options, :current_url

      class << self
        def url_for(fetcher, method)
          # Build path
          u = API_ROOT_URL
          u += "/#{fetcher.sport}"
          u += "/#{method}"
          u += '?'
          # Add parameters
          unless fetcher.options.blank?
            u += self.default_options.merge(fetcher.options).to_param
            # sanitize params
          end
          # After all: add authoriation info
          u += OptaSport.authenticate_params
        end

        def default_options
          {lang: 'en'}
        end


      end

      def sport
        self.class.name.split('::').last.downcase
      end

      # Send request and return response
      def go(method)
        @current_url = self.class.url_for(self, method)
        uri = URI(@current_url)
        response = Net::HTTP.get_response(uri)
        case response
          when Net::HTTPSuccess
            response
          when Net::HTTPBadRequest
            return false
          else
            return false
        end
        response.body
      end
    end


    # =========================================================================
    # Fetcher Classes
    # =========================================================================
    class Soccer < Base
      def get_matches(params)
        # Check required params
        required_params = OptaSport.required_params_for(self.sport, __method__.to_s)
        if required_params.any? { |key| params.stringify_keys.exclude?(key) }
          raise "Error: missing params. Required #{required_params.join(',')}"
        end

        # 'yyyy-mm-dd hh:mm:ss'
        if %w(start_date end_date).any? { |key| params.stringify_keys.exclude?(key) }
          params.merge!(
              start_date: Date.today.beginning_of_day.strftime("%Y-%m-%d %H:%M:%S"),
              end_date: Date.today.end_of_day.strftime("%Y-%m-%d %H:%M:%S"))
        end
        if OptaSport.optional_params_for(self.sport, __method__.to_s)
        end

        @options = params
        res = self.go(__method__.to_s)
        if res
          return SoccerMatchesResult.new(Nokogiri::XML(res))
        else
          return []
        end
      end

      def get_areas
      end
    end
    class Baseball < Base
    end
    class Basketball < Base
    end
    class Handball < Base
    end
    class Hockey < Base
    end
    class Tennis < Base
    end
    class FootballUS < Base
    end

    # =========================================================================
    # Result Classes
    # =========================================================================
    class SoccerMatchesResult
      attr_accessor :xml_doc

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end
    end

    class SoccerAreasResult
    end
  end

  def self.get_all_areas
    uri = URI 'http://api.globalsportsmedia.com/soccer/get_areas?authkey=3f727da50764fd0fa31f6884a68cf75e431ee994&username=cportal'
    xml_result = Nokogiri::XML(Net::HTTP.get_response(uri).body)
    nodes = xml_result.xpath('//area')
    areas = []
    nodes.each do |area|
      areas << Area.create(
          area_id: area['area_id'],
          name: area['name'],
          country_code: area['countrycode'],
          parent_area_id: area.parent['area_id']
      )
    end
    areas
  end

  def self.get_all_competitions
    uri = URI 'http://api.globalsportsmedia.com/soccer/get_competitions?authkey=3f727da50764fd0fa31f6884a68cf75e431ee994&username=cportal'
    xml_result = Nokogiri::XML(Net::HTTP.get_response(uri).body)
    nodes = xml_result.xpath('//competition ')
    competitions = []
    nodes.each do |compt|
      competitions << Competition.create(
          competition_id: compt['competition_id'],
          name: compt['name'],
          area_id: compt['area_id']
      )
    end
    competitions
  end
end