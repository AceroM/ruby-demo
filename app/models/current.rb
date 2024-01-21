class Current < ActiveSupport::CurrentAttributes
  attribute :user

  def onboarded?
    user.onboarded
  end
end
