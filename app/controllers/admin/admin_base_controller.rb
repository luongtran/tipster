class Admin::AdminBaseController < ApplicationController
  USER_TYPE = Admin.name
  layout 'admin'
end