class SettingsController < ApplicationController
  before_action :authenticate_and_set_user!
  before_action :set_subscription!

  def index
  end

  def billing
    @customer = Current.user.customer
    @pagy, @charges = pagy(@subscription.charges.order(created_at: :desc))
  end

  private

  def set_subscription!
    @subscription = Current.user.subscription
    redirect_to start_subscriptions_path unless @subscription
  end
end
