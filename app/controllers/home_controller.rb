class HomeController < ApplicationController
  before_action :subscriber_required

  def index
    @tipsters = Tipster.limit(4)
    if flash[:sign_in_box]
      @show_sign_in_box = true
    end
  end

  def xml_view
    require 'open-uri'
    if params[:sport] == 'football'
      params[:sport] = 'soccer'
    end
    doc = Nokogiri::XML(open("http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=#{params[:sport] || 'soccer'}"))
    events = doc.xpath("//event")
    @results = []
    events.each do |evt|
      eve = {}
      eve["datetime"] = evt.xpath("event_datetimeGMT").text
      eve["league"] = evt.xpath("league").text
      eve["islive"] = evt.xpath("IsLive").text
      evt.xpath("participants//participant").each_with_index do |part, index|
        eve["participiant_name_#{index}"] = part.xpath("participant_name").text
        eve["visit_#{index}"] = part.xpath("visiting_home_draw").text
      end
      evt.xpath("periods//period").each_with_index do |period, index|
        eve["moneyline_visiting"] = period.xpath("moneyline//moneyline_visiting").text
        eve["moneyline_home"] = period.xpath("moneyline//moneyline_home").text
        eve["moneyline_draw"] = period.xpath("moneyline//moneyline_draw").text
      end
      @results.push(eve)
    end
    @results.sort_by { |e| e['datetime'] }
    @sports = Sport.all
  end

  def pricing
    @plans = Plan.all
    @selected_plan = selected_plan
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