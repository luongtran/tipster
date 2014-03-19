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
      "&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3"
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
    # Get all matches of Eng. Premier league now
    # http://api.core.optasports.com/soccer/get_matches?type=season&id=8318&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3
    class SoccerMatch < Base
      def all
        nodes = @xml_doc.css('competition > season > round > match')
        matches = []
        nodes.each do |node|
          competition = node.parent.parent.parent
          matches << {
              match_id: node['match_id'],
              competition_id: competition['competition_id'],
              name: "#{node['team_A_name']} vs #{node['team_B_name']}",
              start_at: "#{node['date_utc']} #{node['time_utc']}".to_datetime,
              status: node['status']
          }
        end
        matches
      end
    end

    class SoccerCompetition < Base
      def all
        nodes = @xml_doc.css('competition')
        competitions = []
        nodes.each do |compt|
          competitions << {
              competition_id: compt['competition_id'],
              name: compt['name'],
              area_id: compt['area_id'],
              country_code: compt['countrycode'],
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
      def all
        nodes = @xml_doc.css('competition > season')
        seasons = []
        nodes.each do |season|
          competition = season.parent
          seasons << {
              season_id: season['season_id'],
              name: season['name'],
              start_date: season['start_date'].to_datetime,
              end_date: season['end_date'].to_datetime,
              competition_id: competition['competition_id'],
          }
        end
        seasons
      end
    end

    class SoccerMatchLive < Base
    end
  end

  # ======================================================================
  # Fetcher Classes
  # ======================================================================

  module Fetcher
    class Base
      attr_accessor :function, :params, :options, :last_url, :success
      class << self
        def url_for(sport, method, params)
          # Create path
          u = API_ROOT_URL
          u += "/#{sport}/#{method}?"

          # Add parameters
          unless params.blank?
            sanitized_params = {}
            params.each do |param, val|
              if val.is_a? DateTime
                sanitized_params[param] = val.strftime(datetime_param_format)
              else
                sanitized_params[param] = val
              end
            end
            u += sanitized_params.to_query
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

      def success?
        !!@success
      end

      # Send request and return response
      def go(method, params, result_class)
        @last_url = self.class.url_for(self.sport, method, params)
        uri = URI(@last_url)
        response = Net::HTTP.get_response(uri)
        if response.is_a? Net::HTTPSuccess
          @success = true
        else
          @success = false
          message = case response
                      when Net::HTTPBadRequest
                        'You have provided a parameter that the function does not support'
                      when Net::HTTPUnauthorized
                        'You have not provided a username/password or authkey'
                      when Net::HTTPForbidden
                        'You have not been authenticated or your subscription does not permit you to request the data you have requested'
                      when Net::HTTPNotFound
                        'You have requested nonexistent data'
                      when Net::HTTPNotImplemented
                        'The sport and/or function you have requested does not exist'
                      when Net::HTTPServerError
                        'Opta XML feed server error'
                      else
                        'Unknown error'
                    end
          return OptaSport::Error.new(
              message: message,
              time: Time.now,
              url: @last_url
          )
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

  class Error
    attr_accessor :message, :url, :time

    def initialize(attrs = {})
      attrs ||= {}
      attrs.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
      return self
    end
  end

end