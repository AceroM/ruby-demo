class AddPhoneVerifiedToOnboardingFlow < ActiveRecord::Migration[7.1]
  def change
    add_column :onboarding_flows, :phone_verified, :timestamp
  end
end
