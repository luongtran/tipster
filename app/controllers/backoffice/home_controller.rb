class Backoffice::HomeController < ApplicationController
  before_action :tipster_required
  def index
  end
end