FactoryBot.define do
  factory :article do
    title { 'test_article' }
    text { 'this is test' }
    slug { 'article' }
    published_at { Time.now }
  end
end
