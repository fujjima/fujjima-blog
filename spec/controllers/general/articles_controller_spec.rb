require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  describe '#index' do
    context 'with draft article' do
      let!(:article){ create :article }
      let!(:draft_article){ create :article, :draft }

      it '公開状態のもののみ公開されていること' do
        get root_path

        expect(response).to have_http_status 200
        expect(response.body).to include(article.text)
        expect(response.body).not_to include(draft_article.text)
      end
    end
  end

  describe '#archives' do
    let(:current){ Time.new(2024, 2, 10) }
    let!(:current_time_article){ create :article, text: '2024年2月公開の記事', published_at: current }

    context '年のみで絞り込みがされている場合' do
      let!(:last_year_article){ create :article, text: '去年公開の記事' }

      before do
        last_year_article.update(published_at: current - 1.year)
      end

      it '指定された年の記事のみ取得されること' do
        get archives_by_year_path(year: 2023)

        expect(response).to have_http_status 200
        expect(response.body).to include(last_year_article.text)
        expect(response.body).not_to include(current_time_article.text)
      end
    end

    context '年月で絞り込みがされている場合' do
      let!(:last_month_article){ create :article, text: '先月公開の記事' }

      before do
        last_month_article.update(published_at: current - 1.month)
      end

      it '指定された年月の記事のみ取得されること' do
        get archives_by_month_path(year: 2024, month: 1)

        expect(response).to have_http_status 200
        expect(response.body).to include(last_month_article.text)
        expect(response.body).not_to include(current_time_article.text)
      end
    end
  end

  xdescribe '#tag' do
  end
end
