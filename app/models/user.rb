class User < ApplicationRecord
  authenticates_with_sorcery!
  enum role: { general: 0, admin: 1 }

  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  # userは一人しかいない想定だが、今後ユーザーを増やす可能性は0ではないため一応uniqueness付けとく
  validates :reset_password_token, presence: true, uniqueness: true, allow_nil: true
  validate :check_if_user_only, on: :create

  def check_if_user_only
    errors.add(:user, '既に上限ユーザー数に達しています') if User.count >= 1
  end
end
