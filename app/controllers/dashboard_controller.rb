class DashboardController < ApplicationController
  before_action :authenticate_and_set_user!

  def index
  end
end
