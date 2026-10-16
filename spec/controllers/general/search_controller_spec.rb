require 'rails_helper'

RSpec.describe SearchController, type: :request do
  describe '#index' do
    context 'HTML の場合' do
      it '検索画面を表示すること' do
        get search_path

        expect(response).to have_http_status 200
        expect(response.body).to include('searchbox__input')
      end
    end

    context 'JSON の場合' do
      let!(:old_article) { create :article, title: 'Rails 入門', published_at: 2.days.ago }
      let!(:new_article) { create :article, title: '日記', text: 'Rails を触った', published_at: 1.day.ago }
      let!(:draft_article) { create :article, :draft, title: 'Rails 下書き' }

      it '公開記事のみ公開日の降順で返すこと' do
        get search_path(format: :json, q: 'rails')

        expect(response).to have_http_status 200
        expect(response.parsed_body).to eq [
          { 'title' => '日記', 'url' => article_path(slug: new_article.slug) },
          { 'title' => 'Rails 入門', 'url' => article_path(slug: old_article.slug) }
        ]
      end

      it '検索語がない場合は空配列を返すこと' do
        get search_path(format: :json, q: ' ')

        expect(response.parsed_body).to eq []
      end
    end
  end
end
