FactoryBot.define do
  factory :article do
    title { 'test_article' }
    text { 'this is test article' }
    slug { SecureRandom.hex(Article::SLUG_HEX_SIZE) }
    published { true }
    published_at { Time.now }
  end

  trait :draft do
    text { 'not published article' }
    published { false }
  end

  trait :with_tags do
    transient do
      tag_name { 'テストタグ' }
    end

    after(:create) do |article, evaluator|
      article.tags << create(:tag, name: evaluator.tag_name)
    end
  end
end
