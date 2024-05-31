# frozen_string_literal: true

require 'ostruct'

# To handle all type of responses from one place
module Respondable
  extend ActiveSupport::Concern

  # ------------- STRUCTS ---------------
  ResponseInfo = ::Struct.new(:type, :status_code, :message, :others)
  ApiResponse = ::Struct.new(:info, :serialized_data, :data, :meta, :pagination, :root_key)

  # ------- INCLUSIVE PROPERTIES --------
  included do
    # ------- CALLBACKS AS MIXIN --------
    before_action :initialize_api_response

    # ----------- ATTRIBUTES ------------
    attr_reader :api_response, :json_to_render
  end

  # -------------- METHODS --------------
  def send_success_response(message = '')
    api_response.info.type = 'success'
    send_response(message)
  end

  def send_notice_response(message = '')
    api_response.info.type = 'notice'
    send_response(message)
  end

  def send_warning_response(message = '')
    api_response.info.type = 'warning'
    send_response(message)
  end

  def send_error_response(exception, message = nil)
    api_response.info.type = 'error'
    api_response.info.message = error_message = message || exception.message

    api_response.info.status_code = ::STATUS_CODES[get_exception_status(exception)]
    backtrace = exception.backtrace.first(15)

    Rails.logger.error(error_message)
    Rails.logger.info "\n -------------- #{backtrace.join("\n -------------- ")}"

    send_response(error_message)
  end

  def send_404_response(message = '')
    raise ::NotFound, message
  end

  def raise_unauthenticated_error!(message = '')
    raise ::Unauthenticated, message
  end

  def raise_forbidden_error!
    raise ::Forbidden, I18n.t('general.errors.unauthorized_action')
  end

  def raise_invalid_parameters(message = '')
    raise Rack::QueryParser::InvalidParameterError, message
  end

  def raise_record_not_found(message = '')
    raise ActiveRecord::RecordNotFound, message
  end

  def raise_record_not_saved(record)
    raise ActiveRecord::RecordNotSaved, record.first_error_message
  end

  def raise_delete_restriction_error(message = '')
    raise message
  end

  def raise_invalid_authenticity_token(message = '')
    raise ActionController::InvalidAuthenticityToken, message
  end

  def send_response(msg = nil)
    set_response_message(msg)
    set_json_response

    set_json_data_root_key
    serialized_data = api_response.serialized_data
    set_json_data(serialized_data)

    set_json_data_pagination
    set_json_data_meta(serialized_data)

    render json: json_to_render.to_h, status: api_response.info.status_code
  end

  # ---------- PRIVATE METHODS ----------
  private

  def initialize_api_response
    @api_response = ApiResponse.new(ResponseInfo.new(nil, 200), {}, {}, {}, {})
    @json_to_render = ::OpenStruct.new(response: {})
  end

  def modified_message(msg = nil)
    case msg
    when Array
      "[#{msg.map { |msg_el| modified_message(msg_el) }.compact.join("\n")}]"
    when Hash, HashWithIndifferentAccess
      "{#{msg.map { |(key, value)| "#{key}: #{modified_message(value)}" }.join(', ')}}"
    else
      message = msg
    end

    return unless message.present?

    message
  end

  def remove_surrounding_brackets(msg = nil)
    return msg unless msg && ['[', '{'].include?(msg&.first) && [']', '}'].include?(msg&.last)

    msg[1...(msg.length - 1)]
  end

  def set_response_message(msg = nil)
    msg = api_response.info.message if msg.blank?
    api_response.info.message = remove_surrounding_brackets(modified_message(msg))
  end

  def set_json_response
    json_to_render.response = api_response.info.to_h.compact
  end

  def set_json_data_root_key
    api_response.root_key = :data unless api_response.root_key.present?
  end

  def set_json_data(serialized_data = nil)
    if serialized_data.present?
      set_json_serialized_data(serialized_data)
    elsif (simple_data = api_response.data).present?
      json_to_render[api_response.root_key] = simple_data
    end
  end

  def set_json_serialized_data(serialized_data = {})
    json_to_render[api_response.root_key] = serialized_data[:data] if serialized_data.key?(:data)
    (serialized_data.except(:data, :meta) || {}).each { |key, value| json_to_render[key] = value }
  end

  def set_json_data_meta(serialized_data = nil)
    metadata = (serialized_data.present? && serialized_data.try(:[], 'meta') || {}).merge(api_response.meta || {})
    json_to_render.meta = metadata if metadata.present?
  end

  def set_json_data_pagination
    json_to_render.pagination = api_response.pagination if api_response.pagination.present?
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
