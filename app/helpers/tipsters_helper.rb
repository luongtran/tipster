module TipstersHelper
  def tipster_statuses_for_select(path)
    # FIXME: the url need to dependency to 'path'
    selected_status = query_params[:status]
    options = []
    options << [
        I18n.t('tipster_statuses.all'),
        'all',
        {data: {url: tipsters_path(query_params.merge(status: nil))}}
    ]
    options << [
        I18n.t('tipster_statuses.active'),
        'active',
        {data: {url: tipsters_path(query_params.merge(status: 'active'))}, selected: selected_status == 'active'}
    ]
    #options << [I18n.t('tipster_statuses.inactive'), 'inactive', {data: {url: tipsters_path(query_params.merge(status: 'inactive'))}, selected: selected_status == 'inactive'}]
    options
  end

  def ranking_sort_by_for_select
    #return []
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
      range == Tipster::DEFAULT_RANKING_RANGE ? 'current' : 'text-muted'
    end
  end

  def sport_filter_param(sport_name)
    query_params.merge(sport: sport_name)
  end

  def ranking_param(range)
    query_params.merge(ranking: range)
  end
end