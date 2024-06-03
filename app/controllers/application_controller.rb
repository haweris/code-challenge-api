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

  helper(*helper_method)
end
