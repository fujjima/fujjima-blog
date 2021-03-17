class User < ApplicationRecord
  authenticates_with_sorcery!
  enum role: { general: 0, admin: 1 }
  validates :password, length: { minimum: 6 }
  validate :check_if_user_only, on: :create

  def check_if_user_only
    errors.add(:user, '既に上限ユーザー数に達しています') if User.count >= 1
  end
end
