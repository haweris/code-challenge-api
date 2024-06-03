# frozen_string_literal: true

# Model for Users for validations, callbacks & custom methods
class User < ApplicationRecord
  # --------------------------------------------------------------------------------------------------------------------
  # MIXINS
  # --------------------------------------------------------------------------------------------------------------------
  include Devise::JWT::RevocationStrategies::Allowlist

  # Include default devise modules. Others available are:
  # :registerable, :rememberable, :validatable,
  # :confirmable, and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :jwt_authenticatable, jwt_revocation_strategy: self

  include ::AuthenticatableUser

  # --------------------------------------------------------------------------------------------------------------------
  # CONSTANTS/ENUMS
  # --------------------------------------------------------------------------------------------------------------------
  RESET_PASSWORD_ENDPOINT = '/auth/new-password?token='

  enum gender: ::PROFILE_GENDERS_ENUM

  # --------------------------------------------------------------------------------------------------------------------
  # ASSOCIATIONS
  # --------------------------------------------------------------------------------------------------------------------
  has_many :articles, foreign_key: 'author_id'

  # --------------------------------------------------------------------------------------------------------------------
  # VALIDATIONS
  # --------------------------------------------------------------------------------------------------------------------
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 5 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: ::EMAIL_REGEX }
  validates :date_of_birth, presence: true, comparison: { less_than_or_equal_to: (Time.now - 5.years) }
  validates :gender, presence: true

  # --------------------------------------------------------------------------------------------------------------------
  # CALLBACKS
  # --------------------------------------------------------------------------------------------------------------------
  after_initialize :set_username!

  # --------------------------------------------------------------------------------------------------------------------
  # INSTANCE METHODS
  # --------------------------------------------------------------------------------------------------------------------
  def send_reset_password_link!(**options)
    reset_password_url, token = options.values_at(:url_origin, :token)
    reset_password_url += RESET_PASSWORD_ENDPOINT
    UserMailer.to(self).with(reset_password_url:, token:).send_reset_password_link.deliver_now
  end

  def identification_name
    profile&.first_name&.squish&.titleize || email.split('@').first
  end

  def set_username!
    return if username.present?

    self.username = email.split('@').first
  end

  # --------------------------------------------------------------------------------------------------------------------
  # PRIVATE INSTANCE METHODS
  # --------------------------------------------------------------------------------------------------------------------

  private

  def fetch_password_errors
    error_list = []
    error_list << 'uppercase' unless password =~ /\p{Upper}/
    error_list << 'lowercase' unless password =~ /\p{Lower}/
    error_list << 'digit' unless password =~ /[[:digit:]]/
    error_list << 'special_character' unless password =~ /[!@#.",'$%^&+=]/
    error_list
  end
end
