module TipstersHelper
  def tipster_statuses_for_select(path)
    selected_status = query_params[:status]
    options = []
    options << [
        I18n.t('tipster_statuses.all'),
        'all',
        'data-url' => build_path_with_params(path, tipster_status_param(nil))
    ]
    options << [
        I18n.t('tipster_statuses.active'),
        'active',
        'data-url' => build_path_with_params(path, tipster_status_param('active')),
        selected: selected_status == 'active'
    ]
    options
  end

  def ranking_sort_by_for_select
    current_raking_sort_by = query_params[:sort]
    options = []
    Tipster::RANKING_SORT_BY.each do |field|
      options << [I18n.t("tipster.ranking.sort_by.#{field}"), field, 'data-url' => tipsters_path(sort_by: field), selected: current_sort_by_param == field]
    end
    options
  end

  def class_for_current_ranking_range(range)
    current_range = query_params[:ranking]
    if current_range.present?
      current_range == range ? 'current' : 'text-muted'
    else
      range == TipsterStatistics::DEFAULT_RANKING_RANGE ? 'current' : 'text-muted'
    end
  end

  def build_path_with_params(path, params={})
    params.delete_if { |key, value| value.nil? }
    if !params.blank?
      return path + '?' + params.to_query
    else
      return path
    end
  end

  def tip_statuses_filter_for_select(path)
    current_tip_status_param = query_params[:status]
    options = []
    options << [I18n.t('common.all'), 0, 'data-url' => build_path_with_params(path, tip_status_param(nil))]
    Tip::STATUSES_MAP.each do |id, key|
      options << [
          I18n.t("tip.statuses.#{Tip::STATUSES_MAP[id]}"),
          key,
          selected: (current_tip_status_param == key),
          'data-url' => build_path_with_params(path, tip_status_param(key))
      ]
    end
    options
  end

  def tip_sport_filter_for_select(path, sports)
    current_sport = query_params[:sport]
    options = []
    options << ['All', nil, 'data-url' => build_path_with_params(path, sport_filter_param(nil))]
    sports.each do |sport|
      options << [
          sport.name.titleize,
          sport.code,
          selected: (current_sport == sport.code),
          'data-url' => build_path_with_params(path, sport_filter_param(sport.code))
      ]
    end
    options
  end

  # Append tip status param
  def tip_status_param(status)
    query_params.merge(status: status)
  end

  # Append tipster status param
  def tipster_status_param(status)
    query_params.merge(status: status)
  end

  # Append sport param
  def sport_filter_param(sport_name)
    query_params.merge(sport: sport_name)
  end

  # Append ranking range param
  def ranking_param(range)
    query_params.merge(ranking: range.parameterize('_'))
  end

end