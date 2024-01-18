class Admin::UsersController < AdminController
  before_action :set_user, only: %i[impersonate]

  def self.ransackable_attributes(auth_object = nil)
    auth_object ? super : []
  end

  def index
  end

  def show
  end

  def impersonate
    raise Unauthorized if @user.admin?
    impersonate_user(@user)
    redirect_to root_path
  end

  def stop_impersonating
    user = Current.user
    stop_impersonating_user
    redirect_to admin_users_index_path(user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
