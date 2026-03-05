Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
end
# TODO: 本番環境ではPOSTリクエストを推奨されるようなので、本番環境用の設定は別途検討する
# https://zenn.dev/shunjuio/articles/b9ffb6565b7409
OmniAuth.config.allowed_request_methods = %i[get]
