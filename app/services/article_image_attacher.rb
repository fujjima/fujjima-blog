# ------------------------------------------------------------

# 記事本文中の画像プレースホルダを、R2 にアップロードした公開 URL へ置換する
#
# 管理画面のエディタは、画像をドロップした時点ではアップロードせず
# 本文に `![name](upload://<uuid>)` を挿入し、ファイル自体はフォーム送信時に
# `article_images[<uuid>]` として本文と一緒に送ってくる。
# ここでは本文に残っているプレースホルダだけをアップロード対象にするため、
# ドロップ後に本文から消した画像は R2 に上がらない。
#
# 引数
#   text:   記事本文（markdown）
#   images: { "<uuid>" => ActionDispatch::Http::UploadedFile } のハッシュ
# 戻り値
#   プレースホルダを公開 URL に置換した本文

# ------------------------------------------------------------
class ArticleImageAttacher
  class Error < StandardError; end
  class MissingImageError < Error; end

  UUID_PATTERN = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
  PLACEHOLDER_PATTERN = %r{upload://(#{UUID_PATTERN.source})}i

  def initialize(text:, images:, uploader_class: Uploader::R2Uploader)
    @text = text.to_s
    @images = (images || {}).transform_keys { |key| key.to_s.downcase }
    @uploader_class = uploader_class
  end

  def call
    uploaded_urls = {}

    @text.gsub(PLACEHOLDER_PATTERN) do
      token = Regexp.last_match(1).downcase
      uploaded_urls[token] ||= upload(token)
    end
  end

  private

  def upload(token)
    file = @images[token]
    unless file.respond_to?(:tempfile)
      raise MissingImageError,
            "本文中の画像（upload://#{token}）に対応するファイルがありません。該当行を削除して画像を再度ドロップしてください"
    end

    @uploader_class.new(file:).upload!
  end
end
