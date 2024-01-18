class AdminController < ApplicationController
  layout "admin"
  before_action :authenticate_and_set_user!
  before_action :authorize_admin!
  before_action :protect_from_impersonification!

  def index
    @query = User.order(id: :desc).ransack(params[:q])
    @search = @query.result(distinct: true)
    @pagy, @users = pagy(@search)
  end

  def components
  end

  def show_flash
    flash_type = params[:flash_type] || "notice"
    respond_to do |f|
      f.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { flash: { flash_type.to_sym => "test" } }) }
      f.html { redirect_to root_path, alert: "No turbo stream" }
    end
  end
  private

  def authorize_admin!
    raise Unauthorized unless Current.user.admin?
  end

  def protect_from_impersonification!
    raise Unauthorized unless Current.user.id == true_user.id
  end
end
