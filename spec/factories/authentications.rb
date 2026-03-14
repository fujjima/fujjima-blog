FactoryBot.define do
  factory :authentication do
    association :user, factory: :user, trait: :admin
    provider { "google" }
    uid { "123456789" }
  end
end
