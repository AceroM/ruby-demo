Rails.application.config.to_prepare do
  Rails.error.subscribe(ErrorsService::Subscriber.new)
end
