module ApplicationHelper
  def my_devise_error_messages!
    return "" if resource.errors.empty?
    messages = ""
    if !resource.errors.empty?
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    messages = messages
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class="alert alert-danger">
    <label>#{sentence}</label>
    <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def set_current_register_step(step_name)
    @current_step == step_name ? 'active' : ''
  end

  def payment_methods_for_select
    options = []
    Payment::PAYMENT_METHODS.each_with_index do |p_m, index|
      options << [p_m.capitalize, index]
    end
    options
  end

  def platforms_for_select
    options = []
    Tip::BET_BOOKMARKERS.each do |pf|
      options << [pf.titleize, pf]
    end
    options
  end

  def event_for_select
    options = []
    require 'open-uri'
    # FIXME: The parsing codes can put here, but the query result should be pass from the controller
    doc = Nokogiri::XML(open("http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=#{params[:sport] || 'soccer'}"))
    events = doc.xpath("//event")

    events.each_with_index do |evt, i|
      eve = {}
      eve["datetime"] = evt.xpath("event_datetimeGMT").text
      eve["league"] = evt.xpath("league").text
      eve["islive"] = evt.xpath("IsLive").text
      evt.xpath("participants//participant").each_with_index do |part, index|
        eve["participiant_name_#{index}"] = part.xpath("participant_name").text
        eve["visit_#{index}"] = part.xpath("visiting_home_draw").text
      end
      options << ["#{eve["participiant_name_0"]} - #{eve["participiant_name_1"]}", "#{eve["participiant_name_0"]} - #{eve["participiant_name_1"]}"]
    end
    options
  end

  def bet_types_for_select
    #options = []
  end

  def query_params
    request.query_parameters
  end

  # Detemine the my_account path for two resources: subscriber or tipster
  def my_account_path_for(user)
    if user.is_a? Tipster
      backoffice_my_account_path
    elsif user.is_a? Subscriber
      my_account_path
    end
  end

  # Detemine the change_password path for two resources: subscriber or tipster
  def change_password_path_for(user)
    if user.is_a? Tipster
      backoffice_change_password_path
    elsif user.is_a? Subscriber
      change_password_path
    end
  end

  # Detemine the change_avatar path for two resources: subscriber or tipster
  def change_avatar_path_for(user)
    if user.is_a? Tipster
      backoffice_change_avatar_path
    elsif user.is_a? Subscriber
      change_avatar_path
    end
  end

  def sort_params_for(field)
    current_sort_param = params[:sort]
    sort_direction = ''

    if current_sort_param.present?
      sort_direction = current_sort_param.split('_').last
      sort_direction = (sort_direction == 'desc') ? 'asc' : 'desc'
    else
      sort_direction = SortingInfo::INCREASE
    end
    query_params.merge(sort: "#{field}_#{sort_direction}")
  end
end
