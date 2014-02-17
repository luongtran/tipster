class TipstersController < ApplicationController
  def top_tipster
    @tipsters = Tipster.all # Just for test
  end
end
