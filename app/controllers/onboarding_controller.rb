class OnboardingController < ApplicationController
  layout "onboarding"
  before_action :authenticate_and_set_user!
  before_action :set_subscription!
  before_action :set_onboarding_flow, only: %i[show update destroy]

  SAAS_PAGES = %w[integrations connect_store finished]
  BANK_PAGES = %w[welcome info disclosures phone_number address business_info kyc kyb link_plaid finished]

  def index
    redirect_to onboarding_path(page: "welcome")
  end

  def show
    if @subscription.saas_plan?
      return render_or_redirect "integrations"
    end
    if @flow.step == "info"
      @info = PersonalInformation.new
    end
    render_or_redirect(params[:page], @flow.step)
  end

  def update
    case @flow.step
    when "welcome"
      unless @flow.required_disclosures.all? { |d| params[d[:form_id]] == "1" }
        return redirect_to onboarding_path(page: "welcome"), notice: "all not accepted"
      end
      client = Synctera::Client.new(user: Current.user)
      if Current.user.synctera?
        user_disclosures = client.disclosures.list(type: "person")
      else
        person = client.persons.create
        business = client.businesses.create
        Current.user.create_synctera_person(platform_id: person["id"], data: person.except(:id))
        Current.user.create_synctera_business(platform_id: business["id"], data: business.except(:id))
        user_disclosures = client.disclosures.list(type: "person")
      end
      disclosures_to_accept = @flow.required_disclosures.pluck(:type) - user_disclosures.pluck("type")
      disclosures_to_accept.each do |disclosure|
        client.disclosures.accept_person_disclosure(disclosure)
      end
      Synctera::Disclosures.sync_all(Current.user)
      @flow.update(accepted_disclosures: Time.current)
      redirect_to onboarding_path(page: "phone_number"), notice: "Disclosures accepted"
    when "phone_number"
      if @flow.verifying_phone?
        unless params[:code].present? && params[:code].match?(/\A\d{6}\z/)
          return redirect_to onboarding_path(page: "phone_number"), alert: "Please enter a valid code"
        end
        verify_code_response = Rails.cache.fetch("twilio-#{@flow.phone_number}", expires_in: 5.seconds) do
          Twilio.verify_code(@flow.phone_number, params[:code])
        end
        if verify_code_response.success? && verify_code_response.body["status"] == "approved"
          @flow.set_phone_verified
          @flow.update(phone_verified: Time.current)
          redirect_to onboarding_path(page: "info")
        elsif verify_code_response.success? && verify_code_response.body["status"] == "pending"
          redirect_to onboarding_path(page: "phone_number"), alert: "Please wait a few seconds and try again."
        else
          redirect_to onboarding_path(page: "phone_number"), alert: "An error occurred verifying your code. Please try again or contact support."
        end
      else
        formatted_number = "+1#{params[:phone_number].gsub(/\D/, '')}"
        unless formatted_number.match?(/\A\+1\d{10}\z/)
          @flow.errors.add(:phone_number, "must be 10 digits")
          return render "onboarding/phone_number", status: :unprocessable_entity
        end
        sent_code_response = Rails.cache.fetch("twilio-#{formatted_number}", expires_in: 5.seconds) do
          Twilio.send_code(formatted_number)
        end
        if sent_code_response.success?
          @flow.set_phone_verifying
          @flow.update(phone_number: formatted_number)
          redirect_to onboarding_path(page: "phone_number")
        else
          redirect_to onboarding_path(page: "phone_number"), alert: "An error occurred sending a verification code. Please try again or contact support."
        end
      end
    when "info"
      @info = PersonalInformation.new(personal_information_params)
      if @info.valid?
        client = Synctera::Client.new(user: Current.user)
        client.persons.save_info(@info)
        client.persons.activate
        Synctera::Persons.sync(Current.user)
        @flow.update(person_organization_linked: Time.current)
        redirect_to onboarding_path(page: "address")
      else
        render "onboarding/info", status: :unprocessable_entity
      end
    when "address"
    else
      redirect_to onboarding_path(page: "not_found")
    end
  rescue StandardError => e
    redirect_to onboarding_path(page: @flow.step), alert: "An error occurred. Please try again or contact support."
  end

  def destroy
    case @flow.step
    when "phone_number"
      @flow.retry_phone_verification
      redirect_to onboarding_path(page: "phone_number")
    else
      redirect_to onboarding_path(page: "not_found")
    end
  rescue
    redirect_to onboarding_path(page: "welcome"), alert: "An error occurred. Please try again or contact support."
  end

  private

  def render_or_redirect(path, step = nil)
    pages = @subscription.saas_plan? ? SAAS_PAGES : BANK_PAGES
    if pages.include?(path) && path == step
      render "onboarding/#{path}"
    elsif pages.include?(path)
      redirect_to onboarding_path(page: step)
    else
      render "onboarding/not_found"
    end
  end

  def set_subscription!
    @subscription = Current.user.subscription
    active = @subscription.try(:active?)
    return redirect_to start_subscriptions_path unless @subscription
    return redirect_to billing_settings_path if !Current.onboarded? && !active
    redirect_to dashboard_path if Current.onboarded? && active
  end

  def set_onboarding_flow
    @flow = Current.user.onboarding_flow || OnboardingFlow.create(user: Current.user)
  end

  def personal_information_params
    params.require(:personal_information).permit(:first_name, :last_name, :dob, :ssn)
  end
end
