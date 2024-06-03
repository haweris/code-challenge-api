# frozen_string_literal: true

# --------------------- ERROR STATUS CODES ---------------------
STATUS_CODES = {
  bad_request: 400,
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  method_not_allowed: 405,
  not_acceptable: 406,
  request_timeout: 408,
  conflict: 409,
  payload_too_large: 413,
  expectation_failed: 417,
  unprocessable_entity: 422,
  internal_server_error: 500,
  not_implemented: 501
}.freeze

# --------------------- EXCEPTION CLASSES ---------------------
BAD_REQUEST_EXCEPTIONS = ['ActionDispatch::Http::Parameters::ParseError',
                          'ActionController::BadRequest',
                          'ActionController::ParameterMissing',
                          'Rack::QueryParser::ParameterTypeError',
                          'Rack::QueryParser::InvalidParameterError'].freeze
UNAUTHORIZED_EXCEPTIONS = ['Unauthenticated'].freeze
FORBIDDEN_EXCEPTIONS = ['Forbidden'].freeze
NOT_FOUND_EXCEPTIONS = ['ActionController::RoutingError',
                        'AbstractController::ActionNotFound',
                        'ActiveRecord::RecordNotFound',
                        'NotFound'].freeze
METHOD_NOT_ALLOWED_EXCEPTIONS = ['ActionController::MethodNotAllowed',
                                 'ActionController::UnknownHttpMethod'].freeze
NOT_ACCEPTABLE_EXCEPTIONS = ['InvalidType',
                             'ActiveRecord::DeleteRestrictionError',
                             'ActionController::UnknownFormat',
                             'ActionDispatch::Http::MimeNegotiation::InvalidType'].freeze
REQUEST_TIMEOUT = ['Net::Timeout', 'RequestTimeout'].freeze
CONFLICT_EXCEPTIONS = ['ActiveRecord::StaleObjectError'].freeze
PAYLOAD_TOO_LARGE = ['PayloadTooLarge'].freeze
EXPECTATION_FAILED_EXCEPTIONS = ['ExpectationFailed'].freeze
UNPROCESSABLE_ENTITY_EXCEPTIONS = ['ActionController::InvalidAuthenticityToken',
                                   'ActionController::InvalidCrossOriginRequest',
                                   'ActiveRecord::RecordInvalid',
                                   'ActiveRecord::RecordNotSaved'].freeze
NOT_IMPLEMENTED_EXCEPTIONS = ['ActionController::NotImplemented'].freeze

# -------------------------- ENUMS ---------------------------
PROFILE_GENDERS_ENUM = {
  male: 'male',
  female: 'female',
  other: 'other',
  unspecified: 'unspecified'
}.freeze

# ----------------------SIMPLE CONSTANTS ---------------------
DISPATCH_REQUESTS = [
  ['POST', %r{/validate_link$}, { scope: :user }],
  ['POST', %r{/sign_in$}, { scope: :user }]
].freeze
REVOCATION_REQUESTS = [['DELETE', %r{/sign_out$}, { scope: :user }]].freeze

# -------------------------- REGEX ---------------------------
# To validate email
EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

# To validate password
PASSWORD_REGEX = /\A(?=.*\p{Lu})(?=.*\p{Ll})(?=.*\d)(?=.*[!@#$%^&+='"|`~]).*\z/
