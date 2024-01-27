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

  def business_type
    Kredis.string("business_type:#{prefix_id}").value
  end

  alias_method :business_type?, :business_type

  def set_business_type(business_type)
    Kredis.string("business_type:#{prefix_id}").value = business_type
  end

  def self.required_disclosures
    [
      {
        "type": "E_SIGN",
        "title": "E-Sign Consent",
        "form_id": :e_sign_consent,
        "url": terms_url
      },
      {
        "type": "CARDHOLDER_AGREEMENT",
        "title": "Cardholder Agreement",
        "form_id": :cardholder_agreement,
        "url": terms_url
      },
      {
        "type": "TERMS_AND_CONDITIONS",
        "title": "Terms and Conditions",
        "form_id": :terms_and_conditions,
        "url": terms_url
      },
      {
        "type": "PRIVACY_NOTICE",
        "title": "Privacy Notice",
        "form_id": :privacy_notice,
        "url": terms_url
      },
      {
        "type": "KYC_DATA_COLLECTION",
        "title": "KYC Data Collection",
        "form_id": :kyc_data_collection,
        "url": terms_url
      }
    ]
  end

  def self.terms_url
    "https://www.example.com/terms"
  end
end
