class SyncteraDisclosure < ApplicationRecord
  belongs_to :user
  belongs_to :synctera_person
  belongs_to :synctera_business
end
