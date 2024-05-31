# frozen_string_literal: true

# To Inherit for authenticated controllers
class AuthController < ApplicationController
  # ------------------ MIXINS -------------------
  include ::Authenticator
end
