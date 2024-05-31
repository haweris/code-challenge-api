# frozen_string_literal: true

# Model for Users for validations, callbacks & custom methods
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
