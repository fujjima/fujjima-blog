require 'rails_helper'

RSpec.describe Admin::ArticlesController, type: :request do
  describe '#create' do
    subject { post admin_articles_path, params: article_params }
    before do
      # TODO: 共通のbefore部分として定義するとか
      admin_user = create(:user, :admin)

      # ref) https://qiita.com/dev-harry/items/0efc80619e314e9540f0
      allow_any_instance_of(described_class)
        .to receive(:current_user)
        .and_return(admin_user)
    end

    let(:article_params) do
      {
        article: {
          title: '作成テストタイトル',
          text: '作成テスト本文',
          published: true
        }
      }
    end

    context '作成に成功した場合' do
      it '記事が作成できること' do
        subject

        expect(response).to have_http_status 302
        expect(response).to redirect_to admin_articles_path
        expect(Article.count).to eq 1
        expect(Article.last.title).to eq '作成テストタイトル'
        expect(Article.last.text).to eq '作成テスト本文'
        expect(Article.last.published).to eq true
      end
    end

    context '作成に失敗した場合' do
      let(:article_params) do
        {
          article: {
            title: '作成テストタイトル',
            text: '作成テスト本文',
            published: nil
          }
        }
      end

      it '記事が作成されずに、編集画面に留まっていること' do
        subject

        expect(response).to have_http_status 200
        expect(Article.count).to eq 0
        expect(flash.now[:alert]).to eq('failed to create')
      end
    end
  end
end
