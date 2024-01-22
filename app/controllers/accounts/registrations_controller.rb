class Accounts::RegistrationsController < Devise::RegistrationsController
  layout "devise"

  def create
    build_resource(sign_up_params)
    resource.save
    UserOnboarding.create!(user: resource)
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :signed_up_but_unconfirmed
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(resource)
    super(resource)
  end
end
