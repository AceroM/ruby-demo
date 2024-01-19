class OnboardingController < ApplicationController
  layout "onboarding"
  before_action :authenticate_and_set_user!
  before_action :set_user_onboarding!

  def index
    redirect_to onboarding_path(id: "welcome")
  end

  def show
    unless Current.onboarding
      render_or_redirect "welcome"
      return
    end
    if Current.onboarding.plaid_connection_time
      render_or_redirect "finished"
    elsif Current.onboarding.kyb_code == "ACCEPTED"
      render_or_redirect "link_plaid"
    elsif Current.onboarding.kyc_code == "ACCEPTED"
      render_or_redirect "kyb"
    elsif Current.onboarding.business_info_collected
      render_or_redirect "kyc"
    elsif Current.onboarding.business_info_saved
      render_or_redirect "business_info"
    elsif Current.onboarding.person_address_saved
      render_or_redirect "business_info"
    elsif Current.onboarding.person_organization_linked
      render_or_redirect "address"
    elsif Current.onboarding.phone_number
      render_or_redirect "info"
    elsif Current.onboarding.accepted_disclosures
      render_or_redirect "phone_number"
    else
      render_or_redirect "not_found"
    end
  end

  private

  def render_or_redirect(path)
    if params[:id] == path
      render path
    else
      redirect_to onboarding_path(id: path)
    end
  end
end
