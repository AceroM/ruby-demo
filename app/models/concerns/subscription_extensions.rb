module SubscriptionExtensions
  extend ActiveSupport::Concern

  included do
    def active?
      return false if canceled?
      return false if paused?
      return false if on_trial?
      status == "active"
    end

    def cancelled?
      status == "canceled" || (ends_at && ends_at <= Time.current)
    end
  end

  def display_status
    return "canceled" if cancelled?
    return "paused" if paused?
    return "trialing" if on_trial?
    status
  end

  def will_pause?
    pause_starts_at? && Time.current < pause_starts_at
  end

  def will_cancel?
    ends_at? && Time.current < ends_at
  end

  def free_plan?
    processor_plan == "free_plan"
  end

  def saas_plan?
    data.dig("subscription_items", 0, "price", "metadata", "type") == "saas"
  end

  def plans
    STRIPE_PLANS.map do |plan|
      plan["current"] = plan["id"] == processor_plan
      plan
    end.sort_by do |plan|
      plan["current"] ? 0 : 1
    end
  end
end
