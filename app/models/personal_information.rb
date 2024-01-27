class PersonalInformation
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :dob, :ssn

  validates :first_name, :last_name, :dob, :ssn, presence: true
  validates :ssn, format: { with: /\A\d{3}-?\d{2}-?\d{4}\z/, message: "must be in the format 123-45-6789" }
  validates :dob, format: { with: /\A\d{4}-?\d{2}-?\d{2}\z/, message: "must be in the format 01/01/2000" }
  validate :dob_is_valid_date_and_before_18_years_ago

  def dob_is_valid_date_and_before_18_years_ago
    if (Date.parse(dob) rescue ArgumentError) == ArgumentError
      errors.add(:dob, "must be a valid date")
    elsif Date.parse(dob) > 18.years.ago
      errors.add(:dob, "must be at least 18 years old")
    end
  end
end
