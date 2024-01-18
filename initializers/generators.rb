Rails.application.config.generators do |g|
  g.test_framework nil,
    fixtures: false,
    view_specs: false,
    helper_specs: false,
    routing_specs: false,
    request_specs: false,
    controller_specs: false
  g.helper false
end
