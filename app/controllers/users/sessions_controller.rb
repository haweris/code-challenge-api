# frozen_string_literal: true

module Users
  # Sessions Controller to Override methods of Devise Session
  class SessionsController < Devise::SessionsController
    # -------------- MIXINS ---------------
    include ::SessionsConcern

    # ------------- CALLBACKS -------------
    skip_before_action :authenticate_user!, except: %i[reset_password]
    before_action :set_resource, only: %i[create forgot_password]
    before_action :set_resource_with_token, only: %i[validate_link]

    # -------------- ACTIONS --------------

    # # ------------------------------------------------------------------------------------------------------------
    # # curl -X POST 'http://0.0.0.0:3000/users' \
    # # -H 'Content-Type: application/json' \
    # --data-raw '{
    #     "user": {
    #         "first_name": "John",
    #         "last_name": "Doe",
    #         "email": "john@grr.la",
    #         "username": "john1,
    #         "gender": "male",
    #         "date_of_birth": "1998-11-19",
    #         "password": "Password@123",
    #         "password_confirmation": "Password@123",
    #     }
    # }'
    # # ------------------------------------------------------------------------------------------------------------
    def sign_up
      self.resource = User.create!(sign_up_params)

      api_response.serialized_data = serialize(resource, only_include: ['articles'])
      send_success_response(I18n.t('users.successes.created'))
    end

    # -----------------------------------------------------------------------------------------------------------
    # curl -X POST 'http://0.0.0.0:3000/sign_in' \
    # --form 'verify_user=false' \
    # --form 'user[email]=user@cca.com' \
    # --form 'user[password]=Password@123' \
    # --form 'user[otp_attempt]=123456' \
    # -----------------------------------------------------------------------------------------------------------
    # /sign_in
    def create
      send_serialized_success_response if authenticated?(raise_exception: true)
    end

    # -----------------------------------------------------------------------------------------------------------
    # curl -X POST 'http://0.0.0.0:3000/sign_out' \
    # -H 'authorization=Gry76JHYcdHjz1rRPnmYipCx'
    # -----------------------------------------------------------------------------------------------------------
    # /sign_out
    def destroy
      if current_user
        send_success_response(I18n.t('sessions.successes.signed_out'))
      else
        send_notice_response(I18n.t('sessions.errors.sign_out_failure'))
      end
    end

    # -----------------------------------------------------------------------------------------------------------
    # curl -X POST 'http://0.0.0.0:3000/forgot_password' \
    # --form 'user[email]=user@cca.com' \
    # -----------------------------------------------------------------------------------------------------------
    # /forgot_password
    def forgot_password
      raise_record_not_found(I18n.t('sessions.errors.user_not_found')) unless resource
      if (Time.now - (resource.reset_password_sent_at || 0)) < 30.seconds
        send_notice_response(I18n.t('sessions.info.reset_password_link_already_sent'))
      else
        send_reset_password_link_to_resource!
        send_success_response(I18n.t('sessions.info.reset_password_link_sent'))
      end
    end

    # -----------------------------------------------------------------------------------------------------------
    # curl -X POST 'http://0.0.0.0:3000/validate_link' \
    # --form 'token=asdfghjklqwertyu' \
    # -----------------------------------------------------------------------------------------------------------
    # /validate_link
    def validate_link
      custom_sign_in
      send_notice_response
    end

    # -----------------------------------------------------------------------------------------------------------
    # curl -X POST 'http://0.0.0.0:3000/reset_password' \
    # -H 'authorization=Gry76JHYcdHjz1rRPnmYipCx'
    # --form 'user[new_password]=Password123@321' \
    # --form 'user[confirm_password]=Password123@321' \
    # -----------------------------------------------------------------------------------------------------------
    # /reset_password
    def reset_password
      ActiveRecord::Base.transaction do
        update_password!
        current_user.clear_reset_password_token!
        sign_out(current_user)
      end

      send_success_response(I18n.t('sessions.successes.reset_password'))
    end

    # ---------- PRIVATE METHODS ----------
    private

    def set_resource
      self.resource = User.where(['lower(email) = :value OR lower(username) = :value', { value: user_email_attempt }])
                          .includes(:articles)
                          .first
    end

    def set_resource_with_token
      self.resource = User.with_reset_password_token(params_token)
    end

    def user_params
      @user_params ||= params.require(:user)
    end

    def sign_up_params
      return @sign_up_params if @sign_up_params.present?

      sign_up_keys = %i[first_name last_name email username gender date_of_birth password password_confirmation]
      sign_up_keys.each do |key|
        user_params.require(key)
      end

      @sign_up_params = user_params.permit(*sign_up_keys)
    end

    def reset_password_params
      return @reset_password_params if @reset_password_params.present?

      user_params.require(:new_password)
      user_params.require(:confirm_password)
      @reset_password_params = user_params.slice(:new_password, :confirm_password)
    end

    def params_token
      params.require(:token)
    end

    def user_email_attempt
      user_params.require(:username).downcase
    end

    def user_password_attempt
      user_params.require(:password)
    end

    def clear_invitation!
      current_user.clear_invitation!
      raise_record_not_saved(current_user) if current_user.errors.any?
    end

    def send_serialized_success_response
      api_response.serialized_data = serialize(resource, only_include: ['articles'], sign_in_request: true)
      send_success_response(I18n.t('sessions.successes.signed_in'))
    end
  end
end
