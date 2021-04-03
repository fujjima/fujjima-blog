require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = build(:user)
  end

  describe 'validate' do
    it 'passwordが6文字以上であればOK' do
      expect(@user.valid?).to eq(true)
    end

    it 'passwordが6文字未満だとNG' do
      @user.password = '12345'
      expect(@user.valid?).to eq(false)
    end

    it 'ユーザー数が2以上だとNG' do
      @user.save!
      user2 = build(:user2)
      expect do
        user2.save!
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: User 既に上限ユーザー数に達しています')
    end
  end
end
