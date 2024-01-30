module ErrorsService
  class Subscriber
    IGNORED_ERRORS = %w[
  ActionController::RoutingError
  AbstractController::ActionNotFound
  ActionController::MethodNotAllowed
  ActionController::UnknownHttpMethod
  ActionController::NotImplemented
  ActionController::UnknownFormat
  ActionController::InvalidAuthenticityToken
  ActionController::InvalidCrossOriginRequest
  ActionDispatch::Http::Parameters::ParseError
  ActionController::BadRequest
  ActionController::ParameterMissing
  ActiveRecord::RecordNotFound
  ActionController::UnknownAction
  ActionDispatch::Http::MimeNegotiation::InvalidType
  Rack::QueryParser::ParameterTypeError
  Rack::QueryParser::InvalidParameterError
  CGI::Session::CookieStore::TamperedWithCookie
  Mongoid::Errors::DocumentNotFound
  Sinatra::NotFound
  Sidekiq::JobRetry::Skip
].map(&:freeze).freeze

    def report(error, handled:, severity:, context:, source: nil)
      return if ignore_by_class?(error.class.name)

      error_attributes = {
        exception_class: error.class.name,
        message: s(error.message),
        severity: severity,
        source: source
      }
      if (record = ErrorsService::Error.find_by(error_attributes))
        record.update!(resolved_at: nil, updated_at: Time.now)
      else
        record = ErrorsService::Error.create!(error_attributes)
      end

      ErrorsService::ErrorOccurrence.create(
        error_id: record.id,
        backtrace: error.backtrace.join("\n"),
        context: s(context)
      )
    end

    def s(data)
      ErrorsService::Sanitizer.sanitize(data)
    end

    def ignore_by_class?(error_class_name)
      IGNORED_ERRORS.any? do |ignored_class|
        ignored_class_name = ignored_class.respond_to?(:name) ? ignored_class.name : ignored_class
        ignored_class_name == error_class_name
      end
    end
  end
end