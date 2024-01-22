class SyncteraPerson < ApplicationRecord
  belongs_to :user
  has_many :synctera_disclosures, dependent: :destroy
end
