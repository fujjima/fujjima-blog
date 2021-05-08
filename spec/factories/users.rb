FactoryBot.define do
  factory :user do
    trait :admin do
      email { 'test@test.com' }
      password { 'password' }
      password_confirmation { 'password' }
      role { 1 }
    end

    trait :general do
      email { 'test2@test.com' }
      password { 'password' }
      password_confirmation { 'password' }
      role { 2 }
    end
  end
end
