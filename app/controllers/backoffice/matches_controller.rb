class Backoffice::MatchesController < Backoffice::BaseController
  def show
    @match = Match.includes(:sport, :competition).find_by!(opta_match_id: params[:id].to_i)
  end
end