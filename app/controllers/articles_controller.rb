# frozen_string_literal: true

# To manage the acions that will handle the routes for articles
class ArticlesController < AuthController
  before_action :set_own_article, only: %i[show update destroy]

  attr_accessor :article

  # # --------------------------------------------------------------------------------------------------------------
  # # curl -X GET 'http://0.0.0.0:3000/articles' \
  # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx'
  # # --------------------------------------------------------------------------------------------------------------
  def index
    articles = if params[:own].present?
                 current_user.articles
               else
                 Article.published
               end

    if (query = params[:q]).present?
      articles = articles.where('title LIKE? OR body LIKE? OR author_name LIKE?', "%#{query}%", "%#{query}%")
    end

    api_response.serialized_data = serialize(articles)
    send_success_response
  end

  # # --------------------------------------------------------------------------------------------------------------
  # # curl -X POST 'http://0.0.0.0:3000/articles' \
  # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx' \
  # # -H 'Content-Type: application/json' \
  # --data '{
  #     "article": {
  #         "title": "Software Engineer",
  #         "body": "Software Engineering is very interesting",
  #         "author_name": "John Doe",
  #     }
  # }'
  # # --------------------------------------------------------------------------------------------------------------
  def create
    strong_params = article_params
    self.article = current_user.articles.create(title: strong_params.delete(:title)&.humanize&.titleize, **strong_params)

    if article.save
      api_response.serialized_data = serialize(article)
      send_success_response(I18n.t('articles.successes.created'))
    else
      raise_record_not_saved(article)
    end
  end

  # # --------------------------------------------------------------------------------------------------------------
  # # curl -X GET 'http://0.0.0.0:3000/articles/:id' \
  # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx' \
  # # -H 'Content-Type: application/json' \
  # # --------------------------------------------------------------------------------------------------------------
  def show
    api_response.serialized_data = serialize(article)
    send_notice_response
  end

  # # --------------------------------------------------------------------------------------------------------------
  # #
  # # Update one or more attribute
  # #
  # # curl -X PUT 'http://0.0.0.0:3000/articles/1' \
  # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx' \
  # # -H  'Content-Type: application/json' \
  # --data '{
  #     "article": {
  #         "title": "Software",
  #         "body": "Software Engineering is interesting",
  #         "author_name": "John",
  #         "published_at": "31-05-2024",
  #    }
  # }'
  # # --------------------------------------------------------------------------------------------------------------
  def update
    if article.update(article_params)
      api_response.serialized_data = serialize(article)
      send_success_response(I18n.t('articles.successes.updated'))
    else
      raise_record_not_saved(article)
    end
  end

  # # --------------------------------------------------------------------------------------------------------------
  # # curl -X DELETE 'http://0.0.0.0:3000/articles/1'
  # # -H 'authorization: Gry76JHYcdHjz1rRPnmYipCx'
  # # --------------------------------------------------------------------------------------------------------------
  def destroy
    if article.destroy
      send_success_response(I18n.t('articles.successes.removed'))
    else
      raise_record_not_saved(article)
    end
  end

  private

  def set_own_article
    self.article ||= current_user.articles.find_by(id: params[:id])
    raise_record_not_found(I18n.t('users.notices.not_permitted')) unless article
  end

  def article_params
    params.require(:article).permit(:title, :body, :author_name, :published_at)
  end
end
