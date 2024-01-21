# frozen_string_literal: true

if Rails.env.production?
  STRIPE_PLANS = YAML.load_file(Rails.root.join("config", "plans.yml"))[:production]
elsif Rails.env.development?
  STRIPE_PLANS = YAML.load_file(Rails.root.join("config", "plans.yml"))[:development]
end
