FactoryBot.define do
  factory :article do
    title { 'test_article' }
    text { 'this is test article' }
    slug { 'published_article' }
    published { true }
    published_at { Time.now }
  end

  trait :draft do
    text { 'not published article' }
    published { false }
  end
end
