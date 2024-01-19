class SubscriptionsController < ApplicationController
  before_action :authenticate_and_set_user!

  def start
  end

  def plans
  end

  private

  def subscribe
    Current.user.set_payment_processor :stripe
  end
end
