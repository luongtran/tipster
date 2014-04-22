class Backoffice::BaseController < ApplicationController
  layout 'backoffice'
  USER_TYPE = Tipster.name

  protected

  def redirect_to_root_path
    redirect_to backoffice_root_path
  end
end