require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:article){ create :article }

  describe 'validate' do
    it 'slugが存在すればOK' do
      expect(article.valid?).to eq(true)
    end

    it 'slugが空欄でも許容する' do
      article.slug = ''
      expect(article.valid?).to be true
    end

    it 'publishedがfalseからtrueに変更された場合、published_atが更新される' do
      not_published_article = build(:article, :draft)
      not_published_article.published = true
      not_published_article.save
      expect(not_published_article.published_at.nil?).to eq(false)
    end
  end
end
