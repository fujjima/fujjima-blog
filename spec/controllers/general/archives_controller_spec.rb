require 'rails_helper'

RSpec.describe ArchivesController, type: :request do
  describe '#index' do
    let!(:article) { create :article, title: '2024年2月の記事' }
    let!(:last_year_article) { create :article, title: '2023年の記事' }
    let!(:draft_article) { create :article, :draft, title: '下書きの記事' }

    before do
      article.update(published_at: Time.zone.local(2024, 2, 10))
      last_year_article.update(published_at: Time.zone.local(2023, 5, 1))
    end

    it '公開済みの記事を年月ごとに表示すること' do
      get archives_path

      expect(response).to have_http_status 200
      expect(response.body).to include(article.title, last_year_article.title)
      expect(response.body).to include(archives_by_year_path(year: 2024), archives_by_month_path(year: 2023, month: 5))
      expect(response.body).not_to include(draft_article.title)
    end
  end
end
