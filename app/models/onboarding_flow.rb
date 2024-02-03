class OnboardingFlow < ApplicationRecord
  has_prefix_id :fl
  belongs_to :user

  def step
    if plaid_connection_time
      "finished"
    elsif kyb_verified
      "link_plaid"
    elsif kyc_verified
      "kyb"
    elsif business_info_collected
      "kyc"
    elsif business_info_saved
      "business_info"
    elsif person_address_saved
      "business"
    elsif person_organization_linked
      "address"
    elsif phone_verified
      "info"
    elsif accepted_disclosures
      "phone_number"
    else
      "welcome"
    end
  end

  def phone_verification_time
    Kredis.datetime("verifying_phone:#{prefix_id}").value
  end

  def verifying_phone?
    return false if phone_number.nil?
    Kredis.datetime("verifying_phone:#{prefix_id}").value.present?
  end

  def set_phone_verifying
    Kredis.datetime("verifying_phone:#{prefix_id}", expires_in: 10.minutes).value = Time.current
  end

  def set_phone_verified
    Kredis.datetime("verifying_phone:#{prefix_id}").del
  end

  alias_method :retry_phone_verification, :set_phone_verified
end
