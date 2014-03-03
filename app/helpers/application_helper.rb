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

  def events_for_select(events)
    options = []
    events.each do |event|
      options << [event.name, event.name]
    end
    options
  end

  def bet_types_for_select
    options = []
    Tip::BET_TYPES_MAP.each do |type_key, type_name|
      options << [type_name, type_key]
    end
    options
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

  def crop_avatar_path_for(user)
    if user.is_a? Tipster
      backoffice_crop_avatar_path
    elsif user.is_a? Subscriber
      crop_avatar_path
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

  def profit_img_chart_url_for(data)
    require 'gchart'
    Gchart.line(
        data: data, :encoding => 'text',
        grid_lines: '16,32,4,0,0,0',
        range_markers: 'B,99999970,0,0,0',
        bg: {
            color: '00000000',
            type: 'gradient'
        },
        graph_bg: {
            type: 'gradient',
            color: '454545,0,121212,1',
            angle: '270'
        },
        line_colors: '7AB5DA',
        :size => '80x40',
    )
  end
end
