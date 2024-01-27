class PersonAddress
  include ActiveModel::Model

  attr_accessor :address_line_one, :address_line_two, :city, :state, :postal_code

  validates :address_line_one, :city, :state, :postal_code, presence: true
  validates :postal_code, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be in the format 12345 or 12345-6789" }
  validates :state, format: { with: /\A[A-Z]{2}\z/, message: "must be a valid state" }
end