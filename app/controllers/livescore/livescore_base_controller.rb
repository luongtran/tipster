class Livescore::LivescoreBaseController < ApplicationController
  layout 'livescore'

  protected
  def set_current_menu
    'home'
  end
end