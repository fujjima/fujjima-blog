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

  # やること
  # 返却されたURLをフロントに返す
  # TODO: google drive関連のクラスを作成し、そこに退避する
  # ここでやるのはパラメータの受け渡しとフロントへの返却ぐらいにする
  def upload_image
    image_file = params[:image]

    File.open(image_file.original_filename, "w+b") do |fp|
      fp.write image_file.read
    end

    # google drive接続関連
    # クラスか、モジュールか
    # クラスの場合、initializeする際のパラメータは？

    # 認証ファイルから必要な情報を取得する
    loaded_credentials = File.open("#{Rails.root}/google-credentials.json") do |j|
      JSON.load(j)
    end

    private_key = OpenSSL::PKey::RSA.new(loaded_credentials["private_key"])
    # GCPの設定ファイルから値を取得してアクセストークン取得を行う
    auth = Signet::OAuth2::Client.new(
      token_credential_uri: loaded_credentials["token_uri"],
      audience: loaded_credentials["token_uri"],
      scope: %w(
        https://www.googleapis.com/auth/drive
      ),
      issuer: loaded_credentials["client_email"],
      signing_key: private_key
    )
    auth.fetch_access_token!

    # google driveにログインした状態を保持する
    session = GoogleDrive.login_with_oauth(auth.access_token)
    folder = session.file_by_title(ENV["GOOGLE_DRIVE_IMAGE_FOLDER_NAME"])
    file_path = "#{Rails.root}/#{image_file.original_filename}"
    folder.upload_from_file(file_path, image_file.original_filename, convert: false)

    File.delete(file_path) if File.exist?(file_path)
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

  def set_article
    @article = Article.find(params[:id])
  end

  def tag_names
    @tag_names = Tag.pluck(:name)
  end
end
