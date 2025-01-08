module ApplicationHelper
  # rubocop:disable Metrics/MethodLength
  def default_meta_tags
    image_url = vite_asset_path('images/icon_800x800.png')
    twitter_account = Rails.env.production? ? ENV['TWITTER_ACCOUNT'] : Rails.application.credentials.twitter_account

    {
      site: 'fujjimablog',
      title: 'fujjimablog',
      reverse: true,
      charset: 'utf-8',
      description: '記事の一覧にアクセス',
      keywords: 'ブログ,技術系,Rails,React,服',
      canonical: request.original_url,
      separator: '|',
      # icon: [
      #   { href: image_url('logo.png') },
      #   { href: image_url('top_image.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png' },
      # ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        # image:,# 配置するパスやファイル名によって変更する
        local: 'ja-JP'
      },
      twitter: {
        card: 'summary',
        site: twitter_account,
        image: image_url
      }
    }
  end
  # rubocop:enable Metrics/MethodLength
end
