class ApplicationController < ActionController::Base
  include Pagy::Backend
  impersonates :user

  class Unauthorized < StandardError; end

  rescue_from ApplicationController::Unauthorized, with: :forbidden

  before_action :authenticate_and_set_user!, if: -> { controller_name == "otp_tokens" }
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  layout proc { |controller|
    if controller_name == "otp_credentials"
      "devise"
    elsif controller.user_signed_in? || controller_name == "otp_tokens"
      "application"
    else
      "unauthenticated"
    end
  }

  def index
    redirect_to dashboard_path
  end

  protected

  def forbidden(exception)
    render html: "Forbidden", status: :forbidden and return
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def configure_devise_permitted_parameters
    keys = [:name, :avatar, :time_zone, :signed_tos, :signed_tos_on]

    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end

  def authenticate_and_set_user!
    authenticate_user!
    if current_user
      Current.user = current_user
      if Current.user.signed_tos_on < Date.new(2023, 4, 25)
        redirect_to edit_user_registration_path, alert: "You must accept the Terms of Service before continuing."
      end
    end
  end

  def set_user_onboarding!
    if Current.user
      Current.onboarding = Current.user.user_onboarding
    end
  end
end
