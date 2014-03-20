# coding: utf-8
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

  def platforms_for_select(platforms)
    options = []
    platforms.each do |pf|
      options << [pf.name.titleize, pf.id]
    end
    options
  end

  def sports_for_select(sports)
    options = []
    sports.each do |sp|
      options << [sp.name.titleize, sp.id]
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

  def bet_types_for_select(bet_types)
    options = []
    bet_types.each do |bet_type|
      if bet_type.has_line?
        options << [bet_type.name.titleize, bet_type.id, 'data-has-line' => true]
      else
        options << [bet_type.name.titleize, bet_type.id]
      end

    end
    options
  end

  def ranking_ranges_for_select
    options = []
    Tipster::RANKING_RANGES.each do |range|
      options << [
          I18n.t("tipster.ranking.ranges.#{range}").titleize,
          range,
          'data-url' => tipster_path(ranking: range),
          selected: current_ranking_range_param == range
      ]
    end
    options
  end

  def class_for_sport_filter(sport)
    current_sport = query_params[:sport]
    current_sport = 'all' if current_sport.nil?
    current_sport == sport ? 'current active' : ''
  end

  def class_for_date_filter(date)
    current_date = query_params[:date]
    current_date = 'today' if current_date.nil?
    current_date == date ? 'disable text-muted' : ''
  end

  def query_params
    request.query_parameters
  end

  def current_date_param
    query_params[:date] ||= 'Today'
  end

  def current_sport_param
    query_params[:sport]
  end

  # Detemine the my_account path for two resources: subscriber or tipster
  def update_profile_path_for(user)
    if user.is_a? Tipster
      backoffice_update_profile_path
    elsif user.is_a? Subscriber
      update_profile_path
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

  # This method nolonger used because we only sort by profit or yield with DESC direction
  #def sort_params_for(field)
  #  current_sort_param = params[:sort]
  #  sort_direction = ''
  #
  #  if current_sort_param.present?
  #    sort_direction = current_sort_param.split('_').last
  #    sort_direction = (sort_direction == 'desc') ? 'asc' : 'desc'
  #  else
  #    sort_direction = SortingInfo::INCREASE
  #  end
  #  query_params.merge(sort: "#{field}_#{sort_direction}")
  #end

  def date_filter_param(date)
    query_params.merge(date: date)
  end

  def profit_img_chart_url_for(data, options = {})
    default_options = {
        size: '70x35'
    }
    options = default_options.merge(options)
    require 'gchart'
    Gchart.line(
        data: data, :encoding => 'extended',
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
        line_colors: 'ACC253',
        :size => options[:size],
    )
  end

  def class_for_link_to_change_lang(lang)
    lang = lang.to_sym
    I18n.locale == lang ? 'current' : ''
  end

  def set_current_menu(menu_name, current)
    menu_name == current ? 'current' : nil
  end

  def genders_collection_for_select
    options = []
    options << [I18n.t('user.male'), true]
    options << [I18n.t('user.female'), false]
    options
  end

  def date_range_filter_for_tips
    date_param = query_params[:date]
    if date_param.present?
      begin
        current_date = date_param.to_date
      rescue => e
        current_date = Date.today
      end
    end
    current_date = Date.today if (current_date.nil? || current_date.future?)
    range = []
    tmp_date = current_date
    if current_date.past?
      range << {value: current_date.next_day.to_s, label: '<< Next day'}
    end
    7.times do |i|
      range << {value: tmp_date.to_s, label: tmp_date.strftime("%b %d")}
      tmp_date = tmp_date.prev_day
    end
    range << {value: current_date.prev_day.to_s, label: 'Prev day >>'}
  end

  def current_sort_by_param
    query_params[:sort_by] ||= Tipster::DEFAULT_RANKING_SORT_BY
  end

  def current_ranking_range_param
    query_params[:ranking] ||= Tipster::DEFAULT_RANKING_RANGE
  end


  def class_for_subscribe_step(step, current_step)
    if step < current_step
      'complete'
    elsif step == current_step
      'current'
    else
      'default'
    end
  end

  def links_for_subscribe_step(step, current_step)
    case step
      when 1
        current_step >= step ? link_to(I18n.t('menu.subscribe.step1'), subscribe_choose_offer_path) : I18n.t('menu.subscribe.step1')
      when 2
        current_step >= step ? link_to(I18n.t('menu.subscribe.step2'), subscribe_choose_tipster_path) : I18n.t('menu.subscribe.step2')
      when 3
        current_step >= step ? link_to(I18n.t('menu.subscribe.step3'), subscribe_personal_information_path) : I18n.t('menu.subscribe.step3')
      when 4
        current_step >= step ? link_to(I18n.t('menu.subscribe.step4'), subscribe_shared_path) : I18n.t('menu.subscribe.step4')
      when 5
        current_step >= step ? link_to(I18n.t('menu.subscribe.step5'), subscribe_receive_methods_path) : I18n.t('menu.subscribe.step5')
      when 6
        current_step >= step ? link_to(I18n.t('menu.subscribe.step6'), subscribe_payment_path) : I18n.t('menu.subscribe.step6')
    end
  end

  def links_for_subscribe_free_step(step, current_step)
    case step
      when 1
        current_step >= step ? link_to(I18n.t('menu.subscribe.step1'), subscribe_choose_offer_path) : I18n.t('menu.subscribe.step1')
      when 2
        current_step >= step ? link_to(I18n.t('menu.subscribe.step3'), subscribe_personal_information_path) : I18n.t('menu.subscribe.step3')
      when 3
        current_step >= step ? link_to(I18n.t('menu.subscribe.step4'), subscribe_shared_path) : I18n.t('menu.subscribe.step4')
      when 4
        I18n.t('menu.subscribe.step4_free')
    end
  end

  def header_menu_adding(size, tipster, plan)
    case size
      when 0
        if tipster
          "Please choose your Subsctiption"
        elsif plan
          "Please choose your TIPSTERHERO"
        end
      else
        "Your SUPER TipsterHero has been added in your shopping cart"
    end
  end

  def header_menu_adding_popup(cart_size, tipster_first)
    case cart_size
      when 0
        if tipster_first
          {
              left: 'Your SUPER TIPSTERHERO',
              right: 'Your Subscription'

          }
        else
          {
              left: 'Your Subscription',
              right: 'Your SUPPER TIPSTERHERO'
          }
        end
      when 1
        if tipster_first
          {
              left: 'Your SUPER TIPSTERHERO',
              right: 'Your Subscription'

          }
        else
          {
              left: 'Your Subscription',
              right: 'Your SUPPER TIPSTERHERO'
          }
        end
      when 2
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
      when 3
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
      when 4
        {
            left: 'SECOND TIPSTERHERO',
            right: 'THIRD TIPSTERHERO'
        }
    end
  end

  def adding_price_show(price)
    "#{(price * 0.4).round(3)} € / month"
  end

  def matches_group_by_for_select
    options = []
    options << ['Date', 'date']
    options << ['Sport', 'date']
    options
  end


  def sport_filter_for_matches(sports)
    options = []
    options << ['All', 0, 'data-url' => filter_matches_backoffice_tips_path(query_params.merge(sport_id: nil))]
    #filter_matches_backoffice_tips_path
    sports.each do |sport|
      options << [sport.name.titleize, sport.id, 'data-url' => filter_matches_backoffice_tips_path(query_params.merge(sport_id: sport.id))]
    end
    options
  end

  def competition_filter_for_matches(competitions)
    options = []
    options << ['All', 0, 'data-url' => filter_matches_backoffice_tips_path(query_params.merge(competition_id: nil))]
    competitions.each do |compt|
      options << ["#{compt.name.titleize} (#{compt.country_code})", compt.id, 'data-url' => filter_matches_backoffice_tips_path(query_params.merge(competition_id: compt.opta_competition_id))]
    end
    options
  end
end
