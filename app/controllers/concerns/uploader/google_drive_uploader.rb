# ------------------------------------------------------------

# google driveへの画像アップローダー
# 引数：アップロードしたいファイル（受け取れる型：ActionDispatch::Http::UploadedFile）
# TODO: jpg.jpegファイルのみ受け取るようにバリデーション的なメソッドが欲しい

# ------------------------------------------------------------
module Uploader
  class GoogleDriveUploader
    extend ActiveSupport::Concern

    def initialize file:
      @file = file
    end

    def upload!(return_upload_file: false)
      file_open

      auth = get_auth_fetched_access_token!
      session = GoogleDrive.login_with_oauth(auth.access_token)
      folder = session.file_by_title(ENV["GOOGLE_DRIVE_IMAGE_FOLDER_NAME"])
      file_path = "#{Rails.root}/#{@file.original_filename}"
      folder.upload_from_file(file_path, @file.original_filename, convert: false)

      # uploaded_file.human_urlで取得できる
      uploaded_file = session.file_by_title(@file.original_filename)

      file_delete file_path
      return uploaded_file if return_upload_file
    end

    private

    def get_auth_fetched_access_token!
      loaded_credentials = fetch_load_credentials
      private_key = OpenSSL::PKey::RSA.new(loaded_credentials["private_key"])
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
      auth
    end

    def file_open
      File.open(@file.original_filename, "w+b") do |fp|
        fp.write @file.read
      end
    end

    def file_delete file_path
      File.delete(file_path) if File.exist?(file_path)
    end


    def fetch_load_credentials
      File.open("#{Rails.root}/google-credentials.json") do |j|
        JSON.load(j)
      end
    end
  end
end
