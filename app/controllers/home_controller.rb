class HomeController < ApplicationController
  before_action :load_subscribe_data

  def index
    @tipsters = Tipster.limit(4)
    if flash[:sign_in_box]
      @show_sign_in_box = true
    end
  end

  def pricing
    if session[:failed_add_tipster_id] || tipster_ids_in_cart.size > 0
      @disable_free = true
    else
      @disable_free = false
    end
    @plans = Plan.all
    @show_checkout_dialog = !!flash[:show_checkout_dialog]
  end

  def select_language
    change_locale params[:locale]
    render json: {}
  end

  def get_matches
    require 'open-uri'
    sport = params[:sport] || "soccer"
    doc = Nokogiri::XML(open("http://api.core.optasports.com/#{sport}/get_matches_live?now_playing=no&minutes=yes&#{API_AUTHENTICATION}"))
    competitions = doc.xpath('//competition')
    @results = []
    competitions.each do |competition|
      competition_name = competition.attr('name')
      area_name = competition.attr('area_name')
      #Competition.new ??
      @matchs = []
      competition.xpath('season//round//match').each do |match|
        #Competition.maths
        @matchs << {
            match_id: match.attr('match_id'),
            date_utc: match.attr('date_utc'),
            time_utc: match.attr('time_utc'),
            team_A_name: match.attr('team_A_name'),
            team_B_name: match.attr('team_B_name')
        }
      end
      @results << {
          competition_name: competition_name,
          area_name: area_name,
          matchs: @matchs
      }
    end
  end
end