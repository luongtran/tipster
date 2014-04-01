class Backoffice::BaseController < ApplicationController
  layout 'backoffice'
  USER_TYPE = Tipster.name
end