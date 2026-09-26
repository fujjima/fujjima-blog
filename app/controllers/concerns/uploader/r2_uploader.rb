# ------------------------------------------------------------

# Cloudflare R2 への画像アップローダー
# 引数：アップロードしたいファイル（受け取れる型：ActionDispatch::Http::UploadedFile）
# 戻り値：アップロードした画像の公開 URL
#
# 認証情報は credentials の r2 配下から取得する
#   account_id / access_key_id / secret_access_key / bucket / public_base_url

# ------------------------------------------------------------
module Uploader
  class R2Uploader
    class ValidationError < StandardError; end

    # マジックバイトで判定した MIME タイプ => R2 上のキーに使う拡張子
    ALLOWED_MIME_TYPES = {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/gif' => 'gif',
      'image/webp' => 'webp'
    }.freeze
    MAX_FILE_SIZE = 10.megabytes
    CACHE_CONTROL = 'public, max-age=31536000, immutable'.freeze

    attr_reader :client

    def initialize(file:, client: nil, config: nil)
      @file = file
      @config = config || Rails.application.credentials.r2 || {}
      @client = client || build_client
    end

    def upload!
      validate!

      key = build_key
      @file.tempfile.rewind
      client.put_object(
        bucket: @config.fetch(:bucket),
        key:,
        body: @file.tempfile,
        content_type: mime_type,
        cache_control: CACHE_CONTROL
      )

      "#{@config.fetch(:public_base_url).chomp('/')}/#{key}"
    end

    private

    def validate!
      raise ValidationError, 'ファイルが指定されていません' unless @file.respond_to?(:tempfile)
      raise ValidationError, "ファイルサイズは #{MAX_FILE_SIZE / 1.megabyte}MB 以下にしてください" if @file.size > MAX_FILE_SIZE
      raise ValidationError, '対応していないファイル形式です（jpeg / png / gif / webp のみ）' unless ALLOWED_MIME_TYPES.key?(mime_type)
    end

    # NOTE: ファイル名や Content-Type は偽装できるため、マジックバイトのみで判定する
    def mime_type
      @mime_type ||= Marcel::MimeType.for(@file.tempfile)
    end

    # NOTE: 元のファイル名は使わない（衝突とパストラバーサルの回避）
    def build_key
      "articles/#{Time.current.strftime('%Y/%m')}/#{SecureRandom.hex}.#{ALLOWED_MIME_TYPES.fetch(mime_type)}"
    end

    def build_client
      Aws::S3::Client.new(
        access_key_id: @config.fetch(:access_key_id),
        secret_access_key: @config.fetch(:secret_access_key),
        endpoint: "https://#{@config.fetch(:account_id)}.r2.cloudflarestorage.com",
        region: 'auto',
        # NOTE: 新しめの aws-sdk は既定で CRC32 チェックサムを付与するが、R2 と噛み合わないことがあるため必要な時だけ計算させる
        request_checksum_calculation: 'when_required',
        response_checksum_validation: 'when_required'
      )
    end
  end
end
