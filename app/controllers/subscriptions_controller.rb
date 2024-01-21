class SubscriptionsController < ApplicationController
  layout "onboarding"

  before_action :authenticate_and_set_user!
  before_action :set_subscription!, only: [:start, :success]

  def start
    Current.user.set_payment_processor :stripe
    Current.user.payment_processor.customer
    @load_stripe = true
    @stripe_plans = STRIPE_PLANS.map { |plan|
      session = Current.user.payment_processor.checkout(
        mode: "subscription",
        line_items: plan[:id],
        subscription_data: { trial_period_days: plan[:trial_period] },
        success_url: success_subscriptions_url,
        cancel_url: billing_settings_url,
      )
      {
        name: plan[:nickname],
        description: plan.dig(:metadata, :description),
        trial_period_days: plan[:trial_period_days],
        price: plan[:amount],
        session: session
      }
    }
  end

  def success
    @plan_name = Current.subscription.try(:data).dig("subscription_items", 0, "price", "nickname")
  end

  def resubscribe
    @customer = Current.user.customer
    @subscription = Current.user.subscription
    unless @customer && @subscription
      return redirect_to start_subscriptions_url, alert: "You are not subscribed to a plan."
    end
    plan_id = params[:plan_id]
    unless plan_id.present? && plan_id.match(/^price_\w+$/) && STRIPE_PLANS.map { |plan| plan["id"] }.include?(plan_id)
      return redirect_to billing_settings_path, alert: "Invalid plan."
    end
    if @subscription
      subscription = Stripe::Subscription.update(@subscription.processor_id, {
        cancel_at_period_end: false,
        billing_cycle_anchor: "now",
        proration_behavior: "always_invoice",
        items: [{
          id: @subscription.data.dig("subscription_items", 0, "id"),
          price: plan_id
        }]
      })
    else
      subscription = Stripe::Subscription.create({
        customer: @customer.processor_id,
        items: [{ price: plan_id }],
        expand: ["latest_invoice.payment_intent"],
      })
    end
    Pay::Stripe::Subscription.sync(subscription.id)
    redirect_to billing_settings_path.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to start_subscriptions_url, alert: "An error occurred while creating your subscription. Please try again or contact support."
  end

  def update
    @subscription = Current.user.subscription
    unless @subscription
      return redirect_to start_subscriptions_path, alert: "You are not subscribed to a plan."
    end
    unless @subscription.active? && @subscription.data.dig("subscription_items").length > 0
      return redirect_to billing_settings_path, alert: "You cannot change your plan while your subscription is paused or canceled."
    end
    plan_id = params[:plan_id]
    unless plan_id.present? && plan_id.match(/^price_\w+$/) && @subscription.plans.map { |plan| plan["id"] }.include?(plan_id)
      return redirect_to billing_settings_path, alert: "Invalid plan."
    end
    Stripe::Subscription.update(@subscription.processor_id, {
      cancel_at_period_end: false,
      billing_cycle_anchor: "now",
      proration_behavior: "always_invoice",
      items: [{
        id: @subscription.data.dig("subscription_items", 0, "id"),
        price: plan_id
      }]
    })
    Pay::Stripe::Subscription.sync(@subscription.processor_id)
    redirect_to billing_settings_path, notice: "Your subscription has been updated."
  rescue Stripe::StripeError => e
    redirect_to billing_settings_path, alert: "An error occurred while updating your subscription. Please try again or contact support."
  end

  def billing
    customer = Current.user.customer
    unless customer
      return redirect_to start_subscriptions_path, alert: "You are not subscribed to a plan."
    end
    url = Rails.cache.fetch("billing_portal_url:#{customer.id}", expires_in: 1.minute) do
      customer.billing_portal_url
    end
    if url
      redirect_to url, allow_other_host: true
    else
      redirect_to billing_settings_path, alert: "An error occurred while loading the billing portal. Please try again or contact support."
    end
  end

  private

  def set_subscription!
    @subscription = Current.user.subscription
    active = @subscription.try(:active?)

    if !@subscription && request.path != start_subscriptions_path
      return redirect_to start_subscriptions_path
    end
    if @subscription && !Current.onboarded?
      return redirect_to billing_settings_path unless active
      return redirect_to onboarding_index_path, notice: "You are already subscribed to a plan."
    end
    if @subscription && Current.onboarded? && active
      redirect_to dashboard_path, notice: "You are already subscribed to a plan."
    end
  end
end
