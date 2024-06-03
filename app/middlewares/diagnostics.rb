# frozen_string_literal: true

class Unauthenticated < StandardError; end
class Forbidden < StandardError; end
class NotFound < StandardError; end
class InvalidType < StandardError; end
class PayloadTooLarge < StandardError; end
class RequestTimeout < StandardError; end
class ExpectationFailed < StandardError; end

# To handle all exception from one place for all controllers
class Diagnostics
  ResponseInfo = ::Struct.new(:type, :status_code, :message)

  attr_reader :response_info

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionController::RoutingError => e
    rescue_exception(env, e, I18n.t('general.errors.routing_error'))
  rescue AbstractController::ActionNotFound => e
    rescue_exception(env, e, I18n.t('general.errors.action_not_found'))
  rescue SyntaxError, StandardError => e
    rescue_exception(env, e)
  end

  private

  def rescue_exception(env, exception, message = nil)
    case env['HTTP_ACCEPT']
    when 'application/json', '*/*'
      rescue_exception_for_json(exception, message)
    else
      raise exception
    end
  end

  def rescue_exception_for_json(exception, message = nil)
    error_message = message || exception.message
    status_code = ::STATUS_CODES[get_exception_status(exception)]
    backtrace = exception.backtrace.first(15)

    @response_info = ResponseInfo.new('error', status_code, error_message)

    Rails.logger.error(error_message)
    Rails.logger.info "\n -------------- #{backtrace.join("\n -------------- ")}"

    [
      status_code, { 'Content-Type' => 'application/json' },
      [{ response_info: response_info.to_h.compact }.to_json]
    ]
  end

  def get_exception_status(exception)
    case exception.class.name
    when *::BAD_REQUEST_EXCEPTIONS then :bad_request
    when *::UNAUTHORIZED_EXCEPTIONS then :unauthorized
    when *::FORBIDDEN_EXCEPTIONS then :forbidden
    when *::NOT_FOUND_EXCEPTIONS then :not_found
    when *::METHOD_NOT_ALLOWED_EXCEPTIONS then :method_not_allowed
    when *::NOT_ACCEPTABLE_EXCEPTIONS then :not_acceptable
    when *::REQUEST_TIMEOUT then :request_timeout
    when *::CONFLICT_EXCEPTIONS then :expectation_failed
    when *::PAYLOAD_TOO_LARGE then :payload_too_large
    when *::EXPECTATION_FAILED_EXCEPTIONS then :conflict
    when *::UNPROCESSABLE_ENTITY_EXCEPTIONS then :unprocessable_entity
    when *::NOT_IMPLEMENTED_EXCEPTIONS then :not_implemented
    else :internal_server_error
    end
  end
end
