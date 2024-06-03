# frozen_string_literal: true

# To serialize article attributes
class ArticleSerializer < AppSerializer
  attributes :title, :body, :author_name, :published_at, :author_id
end
