class User < ApplicationRecord
  has_prefix_id :usr
  broadcasts_refreshes
  pay_customer
  has_one :user_onboarding, dependent: :destroy

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

  def email_confirmed?
    # confirmed_at?
  end

  def admin?
    admin_clearance > 0
  end
end
