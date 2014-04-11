Dir[File.dirname(__FILE__) + '/fetcher/*.rb'].each { |file| require file }
module OptaSport
  module Fetcher
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
      # Define methods : Fetcher.soccer, Fetcher.basketball ... return the responsible class for given sport
      SPORT_TYPE_TO_CLASS.each do |sport_type, klass|
        define_method sport_type do
          return klass.new
        end
      end

      def find_fetcher_for(sport)
        SPORT_TYPE_TO_CLASS[sport.to_s.downcase].try :new
      end
    end
  end
end