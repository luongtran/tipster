# config/initializers/social_buttons.rb
SocialButtons.config do |social|
  social.tweet do |tweet|
    tweet.default_options = {:via => "@tipsterhero"}
  end

  #social.like.default_options = {:via => "myself"}
end
