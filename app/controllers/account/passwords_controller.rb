class Account::PasswordsController < ApplicationController
  before_action :authenticate_and_set_user!

  layout "devise"

  def update
    if Current.user.update_with_password(password_params)
      bypass_sign_in(Current.user)
      redirect_to settings_path, notice: "Password updated successfully."
    else
      redirect_to settings_path, alert: Current.user.errors.full_messages.join(", ")
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
