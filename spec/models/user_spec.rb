require 'rails_helper'

RSpec.describe User, type: :model do
  let(:admin1){ create :user, :admin }
  let(:admin2){ create :user, :admin }

  describe 'validate' do
    it 'passwordが6文字以上であればOK' do
      expect(admin1.valid?).to eq(true)
    end

    it 'passwordが6文字未満だとNG' do
      admin1.password = '12345'
      expect(admin1.valid?).to eq(false)
    end

    it 'ユーザー数が2以上だとNG' do
      admin1.save
      expect do
        admin2.save!
      end.to raise_error(ActiveRecord::RecordInvalid, /既に上限ユーザー数に達しています/)
    end
  end
end
