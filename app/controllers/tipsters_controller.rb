class TipstersController < ApplicationController
  def top_tipster
    @tipster_ids_in_cart = tipster_ids_in_cart
    if params[:period]
      @tipsters = Tipster.order('name DESC').limit(30)
    else
      @tipsters = Tipster.order('id DESC').limit(50)
    end
  end
end
