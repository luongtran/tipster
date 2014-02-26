module TipstersHelper
  def tipster_statuses_for_select
    selected_status = query_params[:status]
    options = []
    options << ['All', 'all', {data: {url: tipsters_path(query_params.merge(status: nil))}}]
    options << ['Active', 'active', {data: {url: tipsters_path(query_params.merge(status: 'active'))}, selected: selected_status == 'active'}]
    options << ['Inactive', 'inactive', {data: {url: tipsters_path(query_params.merge(status: 'inactive'))}, selected: selected_status == 'inactive'}]
    options
  end

  def class_for_sport_filter(sport)
    current_sport = query_params[:sport]
    current_sport = 'all' if current_sport.nil?
    current_sport == sport ? 'btn-primary' : ''
  end

  def sport_filter_param(sport_name)
    query_params.merge(sport: sport_name)
  end
end