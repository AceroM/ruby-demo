class DashboardController < ApplicationController
  before_action :authenticate_and_set_user!
  before_action :set_subscription!

  def index
  end

  private

  def set_subscription!
    @subscription = Current.user.subscription
    active = @subscription.try(:active?)
    return redirect_to start_subscriptions_path unless @subscription
    return redirect_to billing_settings_path if !Current.onboarded? && !active
    redirect_to onboarding_index_path if !Current.onboarded? && active
  end
end
