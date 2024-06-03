# frozen_string_literal: true

module Users
  # Users base controller
  class BaseController < AuthController
    before_action :set_user, only: %i[update]
    before_action :set_user_with_inclusions, only: %i[show]

    attr_accessor :user

    # # ------------------------------------------------------------------------------------------------------------
    # # curl -X PUT/PATCH 'http://0.0.0.0:3000/users/:id' \
    # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx' \
    # # -H 'Content-Type: application/json' \
    # --data-raw '{
    #     "user": {
    #         "first_name": "John",
    #         "last_name": "Doe",
    #         "email": "john@grr.la",
    #         "username": "john1,
    #         "gender": "Male",
    #         "date_of_birth": "1998-11-19",
    #     }
    # }'
    # # ------------------------------------------------------------------------------------------------------------
    def update
      raise_forbidden_error(I18n.t('users.notices.not_permitted')) if current_user != user
      raise_record_not_saved(user) unless user.update(user_update_params)

      api_response.info.message = I18n.t('users.successes.updated')
      send_serialized_response!(serialize(user, current_user:))
    end

    # # ------------------------------------------------------------------------------------------------------------
    # # curl -X GET 'http://0.0.0.0:3000/users/:id/detail' \
    # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx' \
    # # -H 'Content-Type: application/json'
    # # ------------------------------------------------------------------------------------------------------------
    def show
      send_serialized_response!(serialize(user, include: ['articles']))
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      self.user ||= User.find(params.require(:id))
    end

    def set_user_with_inclusions
      self.user ||= User.where(id: params.require(:id)).includes(:articles).first
      return if user

      raise_record_not_found(I18n.t('users.errors.not_found'))
    end

    def user_params
      @user_params ||= params.require(:user)
    end

    # Only allow a list of trusted parameters through.
    def user_permitted_params
      @user_permitted_params ||= user_params.permit(:first_name,
                                                    :last_name,
                                                    :email,
                                                    :username,
                                                    :gender,
                                                    :date_of_birth)
    end

    def send_serialized_response!(serialized_data)
      api_response.serialized_data = serialized_data
      try("send_#{api_response.info.type || 'success'}_response", api_response.info.message)
    end
  end
end
