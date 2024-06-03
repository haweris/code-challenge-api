# frozen_string_literal: true

# To serialize user attributes
class UserSerializer < AppSerializer
  attributes :first_name, :last_name, :full_name, :email, :username, :gender, :date_of_birth, :is_active

  has_many :articles, serializer: ::ArticleSerializer

  def full_name
    "#{object.first_name.humanize.strip} #{object.last_name.humanize.strip}".strip
  end

  def gender
    object.gender.humanize
  end
end
