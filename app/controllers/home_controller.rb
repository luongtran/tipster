class HomeController < ApplicationController
  def index

  end

  def xml_view
    require 'open-uri'
    doc = Nokogiri::XML(open("http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=soccer"))

    Hash.from_xml(doc)["events"]["event"].inject({}) do |result, elem|
      result[elem["name"]] = elem["value"]
      result
    end
    @result = result
    render layout: false
  end

  def pricing
    @plans = Plan.all
    if current_subscriber && current_subscriber.subscription && current_subscriber.subscription.active == true
      @selected_plan = current_subscriber.subscription.plan_id
    else
      @choosed_plan = session[:plan_id]
    end
  end

end