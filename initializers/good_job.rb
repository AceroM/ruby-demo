Rails.application.configure do
  config.good_job = {
    execution_mode: :async,
    queues: '*',
    max_threads: 5,
    poll_interval: 30,
    shutdown_timeout: 25,
    dashboard_default_locale: :en
  }
end
