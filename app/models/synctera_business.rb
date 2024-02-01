class SyncteraBusiness < ApplicationRecord
  belongs_to :user
  has_many :synctera_disclosures
  has_many :synctera_accounts

  def data=(value)
    super(value.except(*excluded_keys).merge("last_updated_time" => value["last_updated_time"]))
  end

  private

  def excluded_keys
    %w[id]
  end
end
