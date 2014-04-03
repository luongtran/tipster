module Bookmarker
  require 'nokogiri'
  module Fetcher
    def go(url)
      uri = URI(ODDS_URL)
      response = Net::HTTP.get_response(uri)
      # TODO: catch timeout error
      Nokogiri::XML(response.body)
    end
  end
end