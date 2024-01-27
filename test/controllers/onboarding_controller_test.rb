require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:joe)

    unless @owner.payment_processor
      @owner.set_payment_processor :fake_processor, allow_fake: true
      @owner.payment_processor.subscribe(plan: "fake_plan")
    end
  end

  test "should be in disclosure page" do
    log_in @user
    get onboarding_url
    assert_response :success
  end
end
