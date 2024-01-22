# frozen_string_literal: true

namespace :stripe do
  desc "List all plans you have synced from stripe"
  task plans: [:environment] do |task, _args|
    puts STRIPE_PLANS
  end
  desc "Sync subscription states from Stripe"
  task sync: [:environment] do |task, _args|
    Pay::Subscription.find_each do |subscription|
      next unless subscription.customer.processor == "stripe"
      Pay::Stripe::Subscription.sync(subscription.processor_id)
    end
    puts "Subscriptions synced successfully."
  end
  desc "Sync payment method states from Stripe"
  task :sync_methods, [:id] => :environment do |task, _args|
    id = _args[:id]
    if id
      list = [User.find(id)].compact
    else
      list = User.all
    end
    list.each do |user|
      next unless user.customer.processor == "stripe"
      Stripe::PaymentMethod.list(customer: user.customer.processor_id).each do |method|
        Pay::Stripe::PaymentMethod.sync(method.id)
      end
    end
  end
  desc "Sync plans config file with the ons in Stripe"
  task sync_plans: [:environment] do |task, _args|
    plans = []
    res = Stripe::Plan.list(limit: 5, active: true)
    loop do
      plans.concat(res.data)
      break unless res.try(:has_more)
      res = Stripe::Plan.list(limit: 5, active: true, starting_after: res.data.last.id)
    end
    plans.filter! { |plan| plan.try(:metadata).try(:description) }
    File.open("config/plans.yml", "w") do |file|
      file.write({ development: plans.as_json, production: [] }.to_yaml)
    end
    puts "Plans synced successfully."
  rescue Stripe::StripeError => e
    puts "Stripe error: #{e.message}"
  rescue => e
    puts "Error: #{e.message}"
  end
end
