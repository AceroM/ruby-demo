class SyncteraAccount < ApplicationRecord
  belongs_to :user
  belongs_to :synctera_business
  belongs_to :synctera_person
end
