# frozen_string_literal: true

require 'uri'

# Application Controller
class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  include ActionController::Helpers
  include ActionController::MimeResponds

  include ::Respondable
  include ::Serialization

  # ----------------- METHODS -------------------
  class << self
    def helper_method(*meths)
      meths
    end
  end

  def process(action, *args)
    params.parse_for_form_data!
    super
  end

  helper(*helper_method)
end
