class User < ApplicationRecord
  authenticates_with_sorcery!

  # NOTE: confirmation: true, xxx_confirmationと値が一致するか検証する
  validates :password, confirmation: true, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validate :check_if_user_only, on: :create

  has_many :authentications, dependent: :destroy

  accepts_nested_attributes_for :authentications

  enum role: { general: 0, admin: 1 }

  def check_if_user_only
    errors.add(:user, '既に上限ユーザー数に達しています') if User.count >= 1
  end
end
