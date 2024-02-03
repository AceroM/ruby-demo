class BusinessInformation
  include ActiveModel::Model

  attr_accessor :business_type, :ein, :business_name, :percent_ownership

  validates :business_type, presence: true, inclusion: { in: %w[sole_proprietorship partnership corporation llc] }
  validates :ein, :business_name, :percent_ownership, presence: true, if: -> { business_type == "sole_proprietorship" }
end
