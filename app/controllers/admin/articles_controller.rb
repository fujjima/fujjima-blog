class Admin::ArticlesController < AdminController
  include Taggable

  protect_from_forgery except: :sort

  before_action :set_article, only: %w[edit update destroy]
  before_action :tag_names, only: %w[new edit]

  def new
    @article = Article.new
  end

  def index
    @articles = if params[:sort_by] && params[:order]
                  # ref) https://stackoverflow.com/questions/25487098/order-an-activerecord-relation-object
                  Article.includes(:tags)
                         .order("#{sort_params[:sort_by]}": sort_params[:order])
                else
                  Article.includes(:tags).order(:id)
                end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit; end

  def create
    slug = SecureRandom.hex(Article::SLUG_HEX_SIZE)
    @article = Article.new(article_params.merge(slug:))

    # TODO: できればタグ付け処理を他に移管したい
    tag_names = tag_names_to_ary(params[:tags])
    @article.tags = tag_names.map do |tag_name|
      find_or_create_tags_by_name(tag_name)
    end

    if save_with_images
      redirect_to admin_articles_path, notice: 'successed to create'
    else
      flash.now[:alert] = 'failed to create'
      render :edit
    end
  end

  def update
    ActiveRecord::Base.transaction do
      # TODO: できればタグ付け処理を他に移管したい
      tag_names = tag_names_to_ary(params[:tags])
      @article.tags = tag_names.map do |tag_name|
        find_or_create_tags_by_name(tag_name)
      end

      @article.assign_attributes(article_params)
      if save_with_images
        redirect_to admin_articles_path, notice: 'successed to update'
      else
        flash.now[:alert] = 'failed to update'
        render :edit
      end
    end
  end

  def destroy
    if @article.destroy
      redirect_to admin_articles_path, notice: 'successed to delete'
    else
      flash.now[:alert] = 'failed to delete'
      render :index
    end
  end

  private

  # TODO: 理想はtagsについても[]で受け取れるようにすること
  def article_params
    params.require(:article).permit(:title, :text, :published, :slug)
  end

  def find_or_create_and_assign_tags(article)
    tag_names = tag_names_to_ary(params[:tags])
    article.tags = tag_names.map do |tag_name|
      Tag.find_or_create_by(name: tag_name)
    end
    article
  end

  # フォーム送信時に本文と一緒に届く画像ファイル（{ "<uuid>" => UploadedFile }）
  # キーは JS が発行した UUID、値はファイル本体。それ以外のものは無視する
  def image_params
    images = params[:article_images]
    return {} unless images.respond_to?(:to_unsafe_h)

    images.to_unsafe_h.select do |token, file|
      token.to_s.match?(/\A#{ArticleImageAttacher::UUID_PATTERN.source}\z/i) && file.respond_to?(:tempfile)
    end
  end

  # バリデーション通過後に本文中の画像を R2 へアップロードし、公開 URL に置換してから保存する
  # 先に valid? を通すことで、保存に失敗する記事のために画像だけ R2 に残ることを防ぐ
  def save_with_images
    return false unless @article.valid?

    @article.text = ArticleImageAttacher.new(text: @article.text, images: image_params).call
    @article.save
  rescue ArticleImageAttacher::Error, Uploader::R2Uploader::ValidationError => e
    @article.errors.add(:text, e.message)
    false
  end

  def sort_params
    params.permit(:sort_by, :order)
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def tag_names
    @tag_names = Tag.pluck(:name)
  end
end
