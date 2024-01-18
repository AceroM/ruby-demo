class Accounts::SessionsController < Devise::SessionsController
  layout "devise"

  after_action :remove_notice, only: [:create, :destroy]

  def sign_in_as
    authenticate_user!
    raise Unauthorized unless current_user&.admin?
    user = User.find_by(email: params[:email])

    if user
      bypass_sign_in(user)
      redirect_to root_path, notice: "Signed in as #{user.email}"
    else
      redirect_back fallback_location: root_path, alert: "User doesn't exist"
    end
  end

  # Override Devise 302 redirect to 303 (:see_other) for Turbo
  #
  # See https://github.com/heartcombo/devise/issues/5458
  def destroy
    super do
      return redirect_to after_sign_out_path_for(resource_name), status: :see_other
    end
  end

  private

  def remove_notice
    flash.delete(:notice)
  end
end
