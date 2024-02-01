module OnboardingHelper
  def render_disclosure_checkbox(disclosure)
    content_tag :label, class: "checkbox", "data-onboarding--welcome-target": ("reference" if disclosure[:click_required].present?) do
      check_box_tag(disclosure[:form_id]) +
        content_tag(:span, "I agree to the ".html_safe + link_to(disclosure[:title], disclosure[:url], class: "link"))
    end
  end
end
