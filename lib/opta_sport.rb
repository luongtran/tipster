require 'active_support/configurable'
require 'nokogiri'

module OptaSport
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
      "&username=#{self.config.username}&authkey=#{self.config.authkey}"
    end
  end

  # ======================================================================
  # Fetching Result Classes
  # ======================================================================
  module FetchResult
    class Base
      attr_accessor :xml_doc

      def initialize(xml_doc)
        @xml_doc = xml_doc
      end
    end
    class SoccerMatch < Base
      def all
        # FIXME: change xpath
        nodes = @xml_doc.xpath('//xxx')
        matches = []
        nodes.each do |node|
          matches << {
              competition_id: node['match'],
              name: node['name'],
              area_id: node['area_id'],
              date: node['date_utc'],
              time: node['time_utc'],
              teams: {
                  a: {
                      id: node['team_A_id'],
                      name: node['team_A_name'],
                      country: node['team_A_country']
                  },
                  b: {
                      id: node['team_B_id'],
                      name: node['team_B_name'],
                      country: node['team_B_country']
                  },
              },
              status: node['status'],
              winner: node['winner']
          }
        end
        competitions
      end
    end

    class SoccerCompetition < Base
      def all
        nodes = @xml_doc.xpath('//competition ')
        competitions = []
        nodes.each do |compt|
          competitions << {
              competition_id: compt['competition_id'],
              name: compt['name'],
              area_id: compt['area_id']
          }
        end
        competitions
      end
    end

    class SoccerArea < Base
      def all
        nodes = @xml_doc.xpath('//area')
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
    end

    class SoccerSeason < Base
    end
    class SoccerMatchLive < Base
    end
  end

  # ======================================================================
  # Fetcher Classes
  # ======================================================================

  module Fetcher
    class Base
      attr_accessor :function, :params, :options, :last_url
      class << self
        def url_for(sport, method, params)
          # Create path
          u = API_ROOT_URL
          u += "/#{sport}/#{method}?"

          # Add parameters
          unless params.blank?
            u += params.to_param
          end

          # After all add authorization infors
          u += OptaSport.authenticate_params
        end

        def default_options
          {lang: 'en'}
        end

        def datetime_param_format
          "%Y-%m-%d %H:%M:%S"
        end
      end

      def sport
        self.class.name.split('::').last.downcase
      end

      # Send request and return response
      def go(method, params, result_class)
        @last_url = self.class.url_for(self.sport, method, params)
        uri = URI(@last_url)
        response = Net::HTTP.get_response(uri)
        case response
          when Net::HTTPSuccess
            response
          when Net::HTTPBadRequest
            return false
          else
            return false
        end
        result_class.new(Nokogiri::XML(response.body))
      end
    end

    class Soccer < Base
      AVAILABLE_FUNCTIONS = {
          'get_areas' => {
              'required_params' => [],
              'options_params' => %w(area_id),
              'result_class' => OptaSport::FetchResult::SoccerArea
          },
          'get_competitions' => {
              'required_params' => [],
              'options_params' => %w(area_id authorized),
              'result_class' => OptaSport::FetchResult::SoccerCompetition
          },
          'get_matches' => {
              'required_params' => %w(id type),
              'options_params' => %w(start_date end_date limit detailed last_updated),
              'result_class' => OptaSport::FetchResult::SoccerMatch
          },
          'get_matches_live' => {
              'required_params' => [],
              'options_params' => %w(id now_playing date minutes detailed type),
              'result_class' => OptaSport::FetchResult::SoccerMatchLive
          },
          'get_seasons' => {
              'required_params' => %w(),
              'options_params' => %w(authorized coverage active id type last_updated),
              'result_class' => OptaSport::FetchResult::SoccerSeason
          }
      }

      AVAILABLE_FUNCTIONS.each do |f_name, settings|
        define_method f_name do |params = {}|
          return self.go(f_name, params, settings['result_class'])
        end
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

    SPORT_TYPE_TO_CLASS = {
        'soccer' => Soccer,
        'football' => Soccer,
        'tennis' => Tennis,
        'baseball' => Baseball,
        'basketball' => Basketball,
        'hockey' => Hockey,
        'football_us' => FootballUS,
        'am_football' => FootballUS,
    }
    class << self
      SPORT_TYPE_TO_CLASS.each do |sport_type, klass|
        define_method sport_type do
          return klass.new
        end
      end
    end

  end


end