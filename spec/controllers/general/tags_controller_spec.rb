require 'rails_helper'

RSpec.describe TagsController, type: :request do
  describe '#index' do
    let!(:article) { create :article, :with_tags, tag_name: '公開タグ' }
    let!(:draft_article) { create :article, :draft, :with_tags, tag_name: '下書きのみのタグ' }

    it '公開記事が紐づくタグのみ表示すること' do
      get tags_path

      expect(response).to have_http_status 200
      expect(response.body).to include(article_tags_path(tag_name: '公開タグ'))
      expect(response.body).not_to include('下書きのみのタグ')
    end
  end
end
