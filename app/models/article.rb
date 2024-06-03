# frozen_string_literal: true

# Model for Articles for validations, callbacks & custom methods
class Article < ApplicationRecord
  # --------------------------------------------------------------------------------------------------------------------
  # ASSOCIATIONS
  # --------------------------------------------------------------------------------------------------------------------
  belongs_to :author, class_name: 'User', required: true

  # --------------------------------------------------------------------------------------------------------------------
  # VALIDATIONS
  # --------------------------------------------------------------------------------------------------------------------
  validates :title, presence: true
  validates :body, presence: true
  validates :published_at,
            comparison: { less_than_or_equal_to: (Time.now + 5.minutes) },
            if: -> { published_at.present? }

  # --------------------------------------------------------------------------------------------------------------------
  # SCOPES
  # --------------------------------------------------------------------------------------------------------------------
  scope :published, -> { where.not(published_at: nil) }
end
