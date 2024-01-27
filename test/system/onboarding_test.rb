require "application_system_test_case"

class OnboardingTest < ApplicationSystemTestCase
  setup do
    @user = users(:joe)
  end

  test "visiting the index" do
    visit onboarding_index_url
    assert_selector "h1", text: "Onboarding"
  end
end
