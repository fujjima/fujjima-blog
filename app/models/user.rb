class User < ApplicationRecord
  has_secure_password
  validate :check_if_user_only, on: :create

  def check_if_user_only
    errors.add(:user, '既に上限ユーザー数に達しています') if User.count >= 1
  end
end
