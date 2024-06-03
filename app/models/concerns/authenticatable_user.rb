# frozen_string_literal: true

# Concerns for User Model
module AuthenticatableUser
  extend ActiveSupport::Concern
  # --------------------------------------------------------------------------------------------------------------------
  # INSTANCE METHODS
  # --------------------------------------------------------------------------------------------------------------------
  def valid_for_authentication?(options = {})
    return true if persisted? && is_active?

    raise_invalid_user_error! if options[:raise_exception]
    false
  end

  def authenticate_with_password!(password_attempt, options = {})
    return true if valid_password?(password_attempt)

    finalize_authentication_with_message(I18n.t('sessions.errors.invalid_credentials'), options)
  end

  def generate_reset_password_token!
    set_reset_password_token
  end

  alias generate_invitation_token! generate_reset_password_token!

  def clear_reset_password_token!
    clear_reset_password_token
    save
  end

  alias clear_invitation! clear_reset_password_token!

  def raise_invalid_user_error!
    raise_unauthenticated_error!(I18n.t('errors.user.not_persisted')) unless persisted?
  end

  # --------------------------------------------------------------------------------------------------------------------
  # PRIVATE INSTANCE METHODS
  # --------------------------------------------------------------------------------------------------------------------
  private

  def finalize_authentication_with_message(message = '', options = {})
    raise_unauthenticated_error!(message) if options[:raise_exception]
    false
  end

  def raise_unauthenticated_error!(message = '')
    raise ::Unauthenticated, message
  end
end
