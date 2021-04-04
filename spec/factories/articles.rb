FactoryBot.define do
  factory :article do
    title { 'test_article' }
    text { 'this is test article' }
    slug { 'published_article' }
    published { true }
  end

  factory :not_published_article, class: Article do
    title { 'test_article' }
    text { 'this is test article' }
    slug { 'not_published_article' }
    published { false }
  end
end
