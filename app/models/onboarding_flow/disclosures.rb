class OnboardingFlow
  class Disclosures
    TERMS_URL = "https://synctera.com/terms-and-conditions".freeze

    def self.required
      [
        {
          "type": "E_SIGN",
          "title": "E-Sign Consent",
          "form_id": :e_sign_consent,
          "click_required": true,
          "url": TERMS_URL
        },
        {
          "type": "CARDHOLDER_AGREEMENT",
          "title": "Cardholder Agreement",
          "form_id": :cardholder_agreement,
          "url": TERMS_URL
        },
        {
          "type": "TERMS_AND_CONDITIONS",
          "title": "Terms and Conditions",
          "form_id": :terms_and_conditions,
          "url": TERMS_URL
        },
        {
          "type": "PRIVACY_NOTICE",
          "title": "Privacy Notice",
          "form_id": :privacy_notice,
          "click_required": true,
          "url": TERMS_URL
        },
        {
          "type": "KYC_DATA_COLLECTION",
          "title": "KYC Data Collection",
          "form_id": :kyc_data_collection,
          "url": TERMS_URL
        }
      ]
    end
  end
end
