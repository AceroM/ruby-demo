class SyncteraPerson < ApplicationRecord
  belongs_to :user
  has_many :synctera_disclosures
  has_many :synctera_accounts
end
