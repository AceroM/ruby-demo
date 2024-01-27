class User < ApplicationRecord
  has_prefix_id :usr
  broadcasts_refreshes
  pay_customer
  has_one :onboarding_flow, dependent: :destroy
  has_one :synctera_person, dependent: :destroy
  has_one :synctera_business, dependent: :destroy
  has_many :synctera_accounts, dependent: :destroy
  has_many :synctera_disclosures, dependent: :destroy

  alias_attribute :disclosures, :synctera_disclosures

  devise :otp_authenticatable, :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :lockable, :timeoutable, :confirmable, :trackable

  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 30 },
    format: { with: /\A[a-zA-Z0-9 ]+\Z/ }

  validates :email, presence: true, uniqueness: true

  attribute :signed_tos, :boolean
  validates :signed_tos_on, presence: true
  validates :signed_tos, acceptance: true

  before_validation if: :signed_tos do
    self.signed_tos_on = Date.today
  end

  alias_method :customer, :payment_processor

  def subscription
    @subscription ||= payment_processor.try(:subscription)
  end

  alias_method :subscribed?, :subscription

  def email_confirmed?
    confirmed_at?
  end

  def synctera?
    synctera_person.present? || synctera_business.present?
  end

  def person_id
    synctera_person.try(:platform_id)
  end

  def business_id
    synctera_business.try(:platform_id)
  end

  def admin?
    admin_clearance > 0
  end
end
