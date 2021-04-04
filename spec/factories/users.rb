FactoryBot.define do
  factory :user do
    trait :admin do
      email { 'test@test.com' }
      password { '123456' }
      role { 1 }
    end

    trait :general do
      email { 'test@test.com' }
      password { '123456' }
      role { 2 }
    end
  end
end
