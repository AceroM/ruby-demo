module CustomerExtensions
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    has_many :payment_methods, -> { order(default: :desc) }, dependent: :destroy
  end

  def billing_portal_url
    @billing_portal_url ||= billing_portal(return_url: billing_settings_url).try(:url)
  end
end
