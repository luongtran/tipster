class Livescore::HomeController < Livescore::LivescoreBaseController
  def index
    @sports = Sport.all
    competitions = Opta::Competition.all
  end
end