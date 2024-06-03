# frozen_string_literal: true

# Application Record class for models to inherit with
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # --------------------------------------------------------------------------------------------------------------------
  # INSTANCE METHODS
  # --------------------------------------------------------------------------------------------------------------------
  def first_error_message
    errors.full_messages.first
  end
end
