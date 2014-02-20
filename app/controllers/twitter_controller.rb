class TwitterController < ApplicationController

  def tweet
    TWITTER_CLIENT.update("I'm tweeting with @gem!")
  end

end
