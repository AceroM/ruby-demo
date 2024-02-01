class SyncteraDisclosure < ApplicationRecord
  belongs_to :user
  belongs_to :synctera_person
  belongs_to :synctera_business

  def data=(value)
    super(value.except(*excluded_keys).merge("last_updated_time" => value["last_updated_time"]))
  end

  private

  def excluded_keys
    %w[id type event_type last_updated_time person_id business_id]
  end
end
