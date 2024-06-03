# frozen_string_literal: true

# Mixin to provide helpful method in sessions
module SessionsConcern
  extend ActiveSupport::Concern

  included do
    # ---------- ATTRIBUTES -----------
    attr_accessor :resource
  end

  # ------------- METHODS -------------
  def skip_jwt_token_dispatch!
    request.env['warden-jwt_auth.token_dispatcher'] = false
  end

  def send_reset_password_link_to_resource!
    raise_record_not_saved(resource) unless (token = resource.generate_reset_password_token!)
    url_origin = if Rails.env.development?
                   'http://localhost:3000'
                 else
                   "https://#{request.host}"
                 end
    Thread.new { resource.send_reset_password_link!(url_origin:, token:) }
  end

  def authenticated?(**options)
    if resource&.valid_for_authentication?(options) && sign_in_user!(options)
      api_response.info.message = I18n.t('sessions.successes.signed_in')
      return true
    end

    raise_invalid_credentials! if options[:raise_exception]
  end

  def sign_in_user!(options = {})
    resource.authenticate_with_password!(user_password_attempt, options)

    custom_sign_in
  end

  def custom_sign_in
    sign_in(resource_name, resource, store: false)
  end

  def update_password!
    password = reset_password_params[:new_password]
    unless password == reset_password_params[:confirm_password]
      raise_invalid_parameters(I18n.t('sessions.errors.password_mismatch'))
    end

    raise_record_not_saved(current_user) unless not_old_password?(password) && current_user.update(password:)
  end

  def not_old_password?(password)
    if current_user.valid_password?(password)
      current_user.errors.add :password, I18n.t('activerecord.errors.models.user.attributes.password.is_old')
      return
    end

    true
  end

  def raise_invalid_link!
    raise_invalid_authenticity_token(I18n.t('general.errors.invalid_or_expired_link'))
  end

  def raise_invalid_credentials!
    raise_unauthenticated_error!(I18n.t('sessions.errors.invalid_credentials'))
  end

  # ---------- DEVISE METHODS ----------

  def respond_to_on_destroy
    true if current_user
  end

  def sign_out(*args)
    super(*args)
    User.revoke_jwt({}, current_user)
    @current_user = nil
  end
end
