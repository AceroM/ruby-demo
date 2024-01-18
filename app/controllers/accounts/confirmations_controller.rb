class Accounts::ConfirmationsController < Devise::ConfirmationsController
  layout "devise"

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    root_path
  end
end
