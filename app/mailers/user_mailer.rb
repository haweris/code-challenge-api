# frozen_string_literal: true

# To send mails to users
class UserMailer < ApplicationMailer
  def send_reset_password_link
    @reset_password_url = "#{params[:reset_password_url]}#{fetch_or_generate_reset_password_token!}"
    mail(to: email_to, subject: reset_password_email_subject)
  end

  private

  def fetch_or_generate_reset_password_token!
    (params[:token] || user.generate_reset_password_token!).to_s
  end

  def reset_password_email_subject
    'RTS - Reset Password link'
  end
end
