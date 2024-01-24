class OnboardingController < ApplicationController
  layout "onboarding"
  before_action :authenticate_and_set_user!
  before_action :set_subscription!

  SAAS_PAGES = %w[integrations connect_store finished]
  BANK_PAGES = %w[welcome info disclosures phone_number address business_info kyc kyb link_plaid finished]

  def index
    redirect_to onboarding_path(page: "welcome")
  end

  def show
    if @subscription.saas_plan?
      return render_or_redirect "integrations"
    end
    if step == "welcome"
      set_required_disclosures
    end
    render_or_redirect(params[:page], step)
  end

  def update
    case step
    when "welcome"
      set_required_disclosures
      disclosures = %i[terms_of_service kyc_data_collection]
      unless disclosures.all? { |d| params[d] == "1" }
        return redirect_to onboarding_path(page: "welcome"), notice: "all not accepted"
      end
      client = Synctera::Client.new(user: Current.user)
      if Current.user.synctera?
        user_disclosures = client.disclosures.list
      else
        person = client.persons.create
        business = client.businesses.create
        Current.user.create_synctera_person(platform_id: person["id"], data: person)
        Current.user.create_synctera_business(platform_id: business["id"], data: business)
        user_disclosures = client.disclosures.list
      end
      (@required_disclosures.map { |d| d["type"] } - user_disclosures.map { |d| d["type"] }).each do |disclosure|
        res = client.disclosures.accept_person_disclosure(disclosure)
        puts res
      end
      Synctera::Disclosures.sync_all(Current.user)
      @flow.update(accepted_disclosures: true)
      redirect_to onboarding_path(page: "phone_number"), notice: "Disclosures accepted"
    else
      redirect_to onboarding_path(page: "not_found")
    end
  rescue StandardError => e
    logger.error e.message
    redirect_to onboarding_path(page: "welcome"), notice: "An error occurred"
  end

  private

  def render_or_redirect(path, step = nil)
    pages = @subscription.saas_plan? ? SAAS_PAGES : BANK_PAGES
    if pages.include?(path) && path == step
      render "onboarding/#{path}"
    elsif pages.include?(path)
      redirect_to onboarding_path(page: step), notice: "You have not made it to this step yet."
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

  def set_required_disclosures
    @required_disclosures = [
      {
        "type": "E_SIGN",
        "title": "E-Sign Consent",
        "form_id": :e_sign_consent,
        "url": terms_url
      },
      {
        "type": "CARDHOLDER_AGREEMENT",
        "title": "Cardholder Agreement",
        "form_id": :cardholder_agreement,
        "url": terms_url
      },
      {
        "type": "TERMS_AND_CONDITIONS",
        "title": "Terms and Conditions",
        "form_id": :terms_and_conditions,
        "url": terms_url
      },
      {
        "type": "PRIVACY_NOTICE",
        "title": "Privacy Notice",
        "form_id": :privacy_notice,
        "url": terms_url
      },
      {
        "type": "KYC_DATA_COLLECTION",
        "title": "KYC Data Collection",
        "form_id": :kyc_data_collection,
        "url": terms_url
      }
    ]
  end

  def step
    @flow = Current.user.onboarding_flow || OnboardingFlow.create(user: Current.user)
    if @flow.plaid_connection_time
      "finished"
    elsif @flow.kyb_code == "ACCEPTED"
      "link_plaid"
    elsif @flow.kyc_code == "ACCEPTED"
      "kyb"
    elsif @flow.business_info_collected
      "kyc"
    elsif @flow.business_info_saved
      "business_info"
    elsif @flow.person_address_saved
      "business_info"
    elsif @flow.person_organization_linked
      "address"
    elsif @flow.phone_number
      "info"
    elsif @flow.accepted_disclosures
      "phone_number"
    else
      "welcome"
    end
  end
end
