class HomeController < ApplicationController
  before_action :subscriber_required

  def index
    @tipsters = Tipster.limit(10)
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
      evt.xpath("periods//period").each_with_index do |period,index|
        eve["moneyline_visiting"] = period.xpath("moneyline//moneyline_visiting").text
        eve["moneyline_home"] = period.xpath("moneyline//moneyline_home").text
        eve["moneyline_draw"] = period.xpath("moneyline//moneyline_draw").text
      end
      @results.push(eve)
    end
    @results.sort_by{|e| e['datetime']}
    @sports = Sport.all
  end

  def pricing
    @plans = Plan.all
    @selected_plan = nil
    if current_subscriber && current_subscriber.has_active_subscription?
      @selected_plan = current_subscriber.subscription.plan_id
    else
      @selected_plan = session[:plan_id]
    end
  end

  def select_language
    change_locale params[:locale]
    render json: {}
  end

  def get_matches
    require 'open-uri'
    sport = params[:sport] || "soccer"
    doc = Nokogiri::XML(open("http://api.core.optasports.com/#{sport}/get_matches_live?now_playing=no&minutes=yes&username=innovweb&authkey=8ce4b16b22b58894aa86c421e8759df3"))
    competitions = doc.xpath('//competition')
    results = []
    competitions.each do |competition|
      competition_name = competition.attr('name')

    end
  end
end