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

  describe '画像付きの保存' do
    let(:token) { 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d' }
    let(:image) do
      Rack::Test::UploadedFile.new(StringIO.new("\x89PNG\r\n\x1a\n".b), 'image/png', original_filename: 'sample.png')
    end
    let(:uploader) { instance_double(Uploader::R2Uploader) }
    let(:url) { 'https://images.example.com/articles/2026/09/0123456789abcdef.png' }

    before do
      admin_user = create(:user, :admin)
      allow_any_instance_of(described_class)
        .to receive(:current_user)
        .and_return(admin_user)

      allow(Uploader::R2Uploader).to receive(:new).and_return(uploader)
      allow(uploader).to receive(:upload!).and_return(url)
    end

    describe '#create' do
      subject { post admin_articles_path, params: article_params }

      let(:article_params) do
        {
          article: {
            title: '画像付き記事',
            text: "本文\n![sample.png](upload://#{token})\n",
            published: true
          },
          article_images: { token => image }
        }
      end

      it '保存時に画像を R2 にアップロードし、本文のプレースホルダを公開 URL に置換して保存すること' do
        subject

        expect(response).to redirect_to admin_articles_path
        expect(Article.count).to eq 1
        expect(Article.last.text).to eq "本文\n![sample.png](#{url})\n"
        expect(Uploader::R2Uploader).to have_received(:new).with(file: an_instance_of(ActionDispatch::Http::UploadedFile))
        expect(uploader).to have_received(:upload!).once
      end

      context '本文から画像が削除されている場合' do
        before { article_params[:article][:text] = '画像なし本文' }

        it '送られてきた画像をアップロードしないこと' do
          subject

          expect(Article.last.text).to eq '画像なし本文'
          expect(uploader).not_to have_received(:upload!)
        end
      end

      context '本文中のプレースホルダに対応するファイルが無い場合' do
        before { article_params.delete(:article_images) }

        it '記事を保存せず、エラーを表示して編集画面に留まること' do
          subject

          expect(response).to have_http_status 200
          expect(Article.count).to eq 0
          expect(flash.now[:alert]).to eq('failed to create')
          expect(response.body).to include("upload://#{token}")
          expect(response.body).to include('対応するファイルがありません')
        end
      end

      context 'Uploader のバリデーションに失敗した場合' do
        before do
          allow(uploader).to receive(:upload!).and_raise(Uploader::R2Uploader::ValidationError, '対応していないファイル形式です')
        end

        it '記事を保存せず、エラーを表示して編集画面に留まること' do
          subject

          expect(response).to have_http_status 200
          expect(Article.count).to eq 0
          expect(response.body).to include('対応していないファイル形式です')
        end
      end

      context '記事のバリデーションに失敗した場合' do
        before { article_params[:article][:published] = nil }

        it '画像をアップロードしないこと' do
          subject

          expect(Article.count).to eq 0
          expect(uploader).not_to have_received(:upload!)
        end
      end
    end

    describe '#update' do
      subject { patch admin_article_path(article), params: article_params }

      let!(:article) { create(:article) }
      let(:article_params) do
        {
          article: {
            title: '更新後タイトル',
            text: "更新後本文\n![sample.png](upload://#{token})",
            published: true
          },
          article_images: { token => image }
        }
      end

      it '保存時に画像を R2 にアップロードし、本文のプレースホルダを公開 URL に置換して更新すること' do
        subject

        expect(response).to redirect_to admin_articles_path
        expect(article.reload.text).to eq "更新後本文\n![sample.png](#{url})"
        expect(uploader).to have_received(:upload!).once
      end
    end
  end
end
