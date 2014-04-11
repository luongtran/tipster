module OptaSport
  module Fetcher
    require 'nokogiri'
    require 'opta_sport/error'
    class Base
      DATETIME_PARAM_FORMAT = "%Y-%m-%d %H:%M:%S"
      attr_accessor :function, :params, :options, :success, :error

      class << self
        def url_for(sport, method, params)
          # Create path
          u = API_ROOT_URL
          u += "/#{sport}/#{method}?"

          # Add parameters
          unless params.blank?
            sanitized_params = {}
            params.each do |key, val|
              if val.is_a? DateTime
                sanitized_params[key] = val.strftime(DATETIME_PARAM_FORMAT)
              elsif val.is_a? TrueClass
                sanitized_params[key] = 'yes'
              elsif val.is_a? FalseClass
                sanitized_params[key] = 'no'
              else
                sanitized_params[key] = val
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
      end

      def sport
        self.class.name.split('::').last.downcase
      end

      def success?
        !!@success
      end

      # Send request and return response
      def go(method, params, result_class)
        puts "\n=== Starting fetch OPTA XML ... \n"
        _url = self.class.url_for(self.sport, method, params)
        response = Net::HTTP.get_response URI(_url)
        if response.is_a? Net::HTTPSuccess
          @success = true
        else
          @success = false
          message =
              case response
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
          @error = OptaSport::Error.new(
              message: message,
              time: Time.now,
              url: _url
          )
        end
        result_class.new(Nokogiri::XML(response.body))
      end # End go function
    end
  end
end