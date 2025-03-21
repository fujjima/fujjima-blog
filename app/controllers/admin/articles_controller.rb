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

  def upload_image
    uploader = Uploader::GoogleDriveUploader.new(file: image_params)
    upload_file = uploader.upload!(return_upload_file: true)

    respond_to do |format|
      format.json { render json: { title: upload_file.title, id: upload_file.id } }
    end
  end

  def create
    slug = SecureRandom.hex(Article::SLUG_HEX_SIZE)
    @article = Article.new(article_params.merge(slug:))

    # TODO: できればタグ付け処理を他に移管したい
    tag_names = tag_names_to_ary(params[:tags])
    @article.tags = tag_names.map do |tag_name|
      find_or_create_tags_by_name(tag_name)
    end

    if @article.save
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
      if @article.save
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

  def image_params
    params.require(:image)
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
