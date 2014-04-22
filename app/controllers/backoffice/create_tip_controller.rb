class Backoffice::CreateTipController < Backoffice::BaseController
  def available_matches
    @bookmarker = Bookmarker.find_by!(code: params[:bookmarker])
    @matches = BookmarkerMatch.betable(params.merge(bookmarker: @bookmarker.code))
  rescue ActiveRecord::RecordNotFound => e
    redirect_to_root_path
  end

  def search_matches
    @bookmarker = Bookmarker.find_by!(code: params[:bookmarker])
    @matches = BookmarkerMatch.betable(params)
    html = render_to_string(
        partial: "backoffice/create_tip/bookmarkers/#{@bookmarker.code}_matches",
        locals: {
            matches: @matches
        }
    )
    render json: {
        success: true,
        html: html
    }
  end

  def manual

  end
end