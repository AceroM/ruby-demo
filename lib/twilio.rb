module Twilio
  TWILIO_BASE_URL = "https://verify.twilio.com/v2/Services".freeze
  VERIFY_SERVICE_ID = Rails.application.credentials.dig(:twilio, :verify, :service_id)
  ACCOUNT_SERVICE_ID = Rails.application.credentials.dig(:twilio, :account, :service_id)
  AUTH_TOKEN = Rails.application.credentials.dig(:twilio, :auth_token)

  def self.send_code(phone_number)
    Faraday.post("#{TWILIO_BASE_URL}/#{VERIFY_SERVICE_ID}/Verifications") do |req|
      req.body = { "To": phone_number, "Channel": "sms" }
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.headers["Authorization"] = "Basic #{Base64.strict_encode64("#{ACCOUNT_SERVICE_ID}:#{AUTH_TOKEN}")}"
    end
  end

  def self.verify_code(phone_number, code)
    Faraday.post("#{TWILIO_BASE_URL}/#{VERIFY_SERVICE_ID}/VerificationCheck") do |req|
      req.body = { "To": phone_number, "Code": code }
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.headers["Authorization"] = "Basic #{Base64.strict_encode64("#{ACCOUNT_SERVICE_ID}:#{AUTH_TOKEN}")}"
    end
  end
end
