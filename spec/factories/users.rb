FactoryBot.define do
  factory :user do
    email { 'test@test.com' }
    password { '123456' }
    role { 1 }
  end

  factory :user2, class: User do
    email { 'test@test2.com' }
    password { '123456' }
    role { 1 }
  end
end
