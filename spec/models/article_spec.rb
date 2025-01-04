require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article) { create :article }

  # TODO: validateの内容ごとにdescribeを分割する
  # TODO: scopeのspec
  describe 'validate' do
    it 'slugが存在すればOK' do
      expect(article.valid?).to eq(true)
    end

    it 'slugが空欄の時はバリデーションエラー' do
      article.slug = ''
      expect(article.valid?).to be false
      expect(article.errors.full_messages).to include("スラグは#{Article::SLUG_BYTE_SIZE}文字で入力してください")
    end
  end

  describe '#update_published_at' do
    it 'publishedがfalseからtrueに変更された場合、published_atが更新される' do
      not_published_article = build(:article, :draft)
      not_published_article.published = true
      not_published_article.save
      expect(not_published_article.published_at.nil?).to eq(false)
    end
  end

  describe 'group_by_***' do
    before do
      # NOTE: 検証のためコールバックを一時的に解除する
      Article.skip_callback(:save, :before, :update_published_at)
    end

    after do
      # NOTE: 検証のため解除したコールバックを復活させる
      Article.set_callback(:save, :before, :update_published_at)
    end

    describe 'group_by_monthly' do
      subject { Article.group_by_monthly }

      before do
        3.times do |i|
          published_at = Time.new(2024, i + 1, 1)
          days = [published_at.beginning_of_month, published_at.since(15.days), published_at.end_of_month]
          days.each do |day|
            create(:article,
                   title: "公開中の記事#{i + 1}",
                   text: '',
                   published_at: day)
          end
        end
      end

      it '公開月によってグルーピングされて返却されていること' do
        expect(subject.keys).to contain_exactly('2024/01', '2024/02', '2024/03')
        expect(subject['2024/01'].count).to eq 3
        expect(subject['2024/02'].count).to eq 3
        expect(subject['2024/03'].count).to eq 3
      end
    end

    describe 'group_by_yearly' do
      subject { Article.group_by_yearly }

      before do
        years = [2023, 2024]
        days = ['1/1', '6/1', '12/31']

        years.each do |year|
          days.each do |day|
            published_at = Time.parse("#{year}/#{day}")

            create(:article,
                   title: '公開中の記事',
                   text: '',
                   published_at:)
          end
        end
      end

      it '公開年によってグルーピングされて返却されていること' do
        expect(subject.keys).to contain_exactly('2023', '2024')
        expect(subject['2023'].count).to eq 3
        expect(subject['2024'].count).to eq 3
      end
    end
  end
end
