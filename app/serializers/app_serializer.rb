# frozen_string_literal: true

# Serializer to inherit for all serializers for common attributes
class AppSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at

  def current_user
    @current_user ||= @instance_options[:current_user]
  end
end
