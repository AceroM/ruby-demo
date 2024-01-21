class OnboardingController < ApplicationController
  layout "onboarding"
  before_action :authenticate_and_set_user!
  before_action :set_subscription!
  before_action :set_onboarding_flow, only: [:show]

  def index
    redirect_to onboarding_path(page: "welcome")
  end

  def show
    unless @flow
      return render_or_redirect "welcome"
    end
    if @flow.plaid_connection_time
      render_or_redirect "finished"
    elsif @flow.kyb_code == "ACCEPTED"
      render_or_redirect "link_plaid"
    elsif @flow.kyc_code == "ACCEPTED"
      render_or_redirect "kyb"
    elsif @flow.business_info_collected
      render_or_redirect "kyc"
    elsif @flow.business_info_saved
      render_or_redirect "business_info"
    elsif @flow.person_address_saved
      render_or_redirect "business_info"
    elsif @flow.person_organization_linked
      render_or_redirect "address"
    elsif @flow.phone_number
      render_or_redirect "info"
    elsif @flow.accepted_disclosures
      render_or_redirect "phone_number"
    else
      render_or_redirect "not_found"
    end
  end

  def update
    redirect_to onboarding_path(page: "welcome"), notice: "ASdf"
  end

  private

  def render_or_redirect(path)
    if params[:page] == path
      render "onboarding/#{path}"
    else
      redirect_to onboarding_path(page: path)
    end
  end

  def set_subscription!
    @subscription = Current.user.subscription
    active = @subscription.try(:active?)
    return redirect_to start_subscriptions_path unless @subscription
    return redirect_to billing_settings_path if !Current.onboarded? && !active
    redirect_to dashboard_path if Current.onboarded? && active
  end

  def set_onboarding_flow
    @flow = Current.user.user_onboarding
  end
end
