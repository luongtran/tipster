module TipstersHelper
  def tipster_statuses_for_select
    selected_status = query_params[:status]
    options = []
    options << [I18n.t('tipster_statuses.all'), 'all', {data: {url: tipsters_path(query_params.merge(status: nil))}}]
    options << [I18n.t('tipster_statuses.active'), 'active', {data: {url: tipsters_path(query_params.merge(status: 'active'))}, selected: selected_status == 'active'}]
    #options << [I18n.t('tipster_statuses.inactive'), 'inactive', {data: {url: tipsters_path(query_params.merge(status: 'inactive'))}, selected: selected_status == 'inactive'}]
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