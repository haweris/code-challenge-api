# frozen_string_literal: true

# For configuring the mailer
class ApplicationMailer < ActionMailer::Base
  default from: 'haweris.warraich@gmail.com'
  # layout 'notification_mailer'

  attr_reader :params, :email_to, :user

  def self.to(resource)
    mailer = new
    mailer.instance_variable_set(:@user, resource)
    mailer.instance_variable_set(:@email_to, resource.email)

    mailer
  end

  def with(**args)
    self.params = args
    self
  end
end
