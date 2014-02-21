class TwitterController < ApplicationController

  def tweet
    client = TwitterOAuth::Client.new(
        :consumer_key => TWITTER_CONSUMER_KEY,
        :consumer_secret => TWITTER_CONSUMER_SECRET
    )
    access_token = client.authorize(
        session[:request_token].token,
        session[:request_token].secret,
        :oauth_verifier => params[:oauth_verifier]
    )
    puts client.authorized?
    client.update('@quang @luan @sfrteam Tweeter') # sends a twitter status update
  end
end
