# frozen_string_literal: true

# To authenticate requests
module Authenticator
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    raise_unauthenticated_error!(I18n.t('sessions.errors.unauthenticated')) unless current_user
    current_user.valid_for_authentication?(raise_exception: true)
  end
end
