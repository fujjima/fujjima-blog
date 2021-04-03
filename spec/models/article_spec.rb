require 'rails_helper'

RSpec.describe Article, type: :model do
  before do
    @article = build(:article)
  end

  describe 'validate' do
    it 'slugが存在すればOK' do
      expect(@article.valid?).to eq(true)
    end

    it 'slugが空欄だとNG' do
      @article.slug = ''
      expect(@article.valid?).to eq(false)
    end

    it 'publishedがfalseからtrueに変更された場合、published_atが更新される' do
      not_published_article = build(:not_published_article)
      not_published_article.published = true
      not_published_article.save
      expect(not_published_article.published_at.nil?).to eq(false)
    end
  end
end
