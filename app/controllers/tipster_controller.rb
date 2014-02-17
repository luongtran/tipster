class TipsterController < ApplicationController
  def top_tipster
    @tipster = Tipster.all # Just for test
  end
end
