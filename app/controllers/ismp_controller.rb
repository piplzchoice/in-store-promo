class IsmpController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: IsmpController

  def index
  end
end
