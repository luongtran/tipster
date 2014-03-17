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

    def available_sprorts
      %w(soccer baseball basketball handball hockey rugby tennis)
    end

    def available_functions
    end

    def config
      @config
    end

    def authenticate_params
      "&username=#{self.config.username}&authkey=#{self.config.authkey}"
    end

    AVAILABLE_SPORTS.each do |sport|
      define_method sport.to_sym do
        return "#{self.name}::Fetcher::#{sport.capitalize}".constantize.new
      end
    end

    def get_football_areas
      fetcher = Fetcher.new(
          SOCCER,
          function: 'get_areas'
      )
      xml_result = fetcher.go!
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
      xml_result = fetcher.go!
    end
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :username
    config_accessor :authkey
  end

  module Fetcher
    class Base
      #include ActiveRecord::ReadonlyAttributes
      attr_accessor :function, :options

      class << self
        def url_for(fetcher)
          u = API_ROOT_URL
          u << "/#{fetcher.sport}"
          u << "/#{fetcher.function}"
          u << '?'
          if fetcher.options
            u << options.to_param
          end
          # After all: append authoriation info
          u << OptaSport.authenticate_params
        end
      end

      def sport
        self.class.name.split('::').last.downcase
      end

      def go!
        Nokogiri::XML(open(self.class.url_for(self)))
      end

      def get_areas
      end

      def get_compettions
      end

      def get_seasons
      end

      def get_teams
      end

      def get_matches
      end

      def get_matches_live
      end
    end

    class Soccer < Base
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
  end
end