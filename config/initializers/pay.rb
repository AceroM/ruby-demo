# frozen_string_literal: true

Pay.setup do |config|
  config.enabled_processors = [:stripe, :fake_processor]
  config.application_name = "Ruby"
  config.support_email = "Ruby <support@spendruby.com>"

  # Configure which emails to set. Note that payment
  # processor might also be sending emails.
  config.emails.payment_action_required = true
  config.emails.receipt = true
  config.emails.refund = true
end

Rails.application.config.to_prepare do
  Pay::Subscription.include SubscriptionExtensions
  Pay::Customer.include CustomerExtensions
end
