class TwitterController < ApplicationController

  def tweet
    require "rubygems"
    require "twitter"
    Twitter.configure do |config|
      config.consumer_key = ' << your consumer key >>'
      config.consumer_secret =  ' << your consumer secret >>'
      config.oauth_token = ' << your access token >> '
      config.oauth_token_secret = '<< your access token secret >>'

    end
    client = Twitter::Client.new
  end

end
