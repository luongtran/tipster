class HomeController < ApplicationController
  def index
    params[:q] ||= {}
    q = Tipster.search(params[:q])
    @tipsters = q.result
  end

  def xml_view
    require 'open-uri'
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
      @results.push(eve)
    end
    @sports = Sport.all
  end

  def pricing
    @plans = Plan.all
    if current_user && current_user.subscription && current_user.subscription.active == true
      @selected_plan = current_user.subscription.plan_id
    else
      @choosed_plan = session[:plan_id]
    end
  end

  def select_language
    session[:locale] = params[:locale]
    # FIXME: refresh current page
    render js: 'window.location = "/"'
  end

end