class HomeController < ApplicationController
  before_action :subscriber_required

  def index
    params[:q] ||= {}
    q = Tipster.search(params[:q])
    @tipsters = q.result
    if flash[:sign_in_box]
      @show_sign_in_box = true
    end
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

end