Rails.application.config.to_prepare do
  class Setup
    attr_reader :user, :email, :flow, :client

    def initialize
      unless Rails.env.development?
        raise StandardError, "This initializer should only be used in development"
      end
      @user = User.find_by(admin_clearance: 2)
      @email = @user.email
      @flow = user.onboarding_flow
      @client = Synctera::Client.new(user: user)
    end

    def copy_email
      IO.popen("pbcopy", "w") { |f| f << email }
    end
  end
end
