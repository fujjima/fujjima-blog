class Admin::ArticlesController < AdminController
  include Taggable
  before_action :set_article, only: %w[edit update destroy]
  before_action :tag_names, only: %w[new edit]

  def new
    @article = Article.new
  end

  def index
    @articles = Article.includes(:tags)
                       .order(:id)
  end

  def edit; end

  def upload_image
    uploader = Uploader::GoogleDriveUploader.new(file: image_params)
    upload_file = uploader.upload!(return_upload_file: true)

    respond_to do |format|
      format.json { render json: upload_file.human_url }
    end
  end

  def create
    # TODO: 新規作成時にタグが紐づけられていないので修正
    @article = Article.new(article_params)
    if @article.save
      redirect_to admin_articles_path, notice: "successed to create"
    else
      flash.now[:alert] = "failed to create"
      render :edit
    end
  end

  def update
    ActiveRecord::Base.transaction do
      tag_names_ary = tag_names_to_ary(params[:tags])
      Tag.insert_new_tag(tag_names_ary)
      @article.tags.replace(from_tag_names_ary_to_tag_instances_ary(tag_names_ary))

      @article.assign_attributes(article_params)
      if @article.save
        redirect_to admin_articles_path, notice: "successed to update"
      else
        flash.now[:alert] = "failed to update"
        render :edit
      end
    end
  end

  def destroy
    if @article.destroy
      redirect_to admin_articles_path, notice: "successed to delete"
    else
      flash.now[:alert] = "failed to delete"
      render :index
    end
  end

  private

  # TODO: 理想はtagsについても[]で受け取れるようにすること
  def article_params
    params.require(:article).permit(:title, :text, :published, :slug)
  end

  def image_params
    params.require(:image)
  end

  def set_article
    @article = Article.find(params[:id])
  end

  def tag_names
    @tag_names = Tag.pluck(:name)
  end
end
