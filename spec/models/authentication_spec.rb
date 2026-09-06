require 'rails_helper'

RSpec.describe Authentication, type: :model do
  let!(:user) { create :user, :admin }
  let!(:authentication) { create :authentication, user: user }

  describe 'association' do
    it 'userに紐づけたauthenticationが存在していること' do
      expect(authentication.user).to eq(user)
    end
  end

  describe 'validation' do
    it 'userがなければNG' do
      auth = build(:authentication, user: nil)
      expect(auth.valid?).to eq(false)
    end

    it 'providerがなければNG' do
      auth = build(:authentication, user: user, provider: nil)
      expect(auth.valid?).to eq(false)
    end

    it 'uidがなければNG' do
      auth = build(:authentication, user: user, uid: nil)
      expect(auth.valid?).to eq(false)
    end

    it '同一のproviderとuidの組み合わせは重複NG' do
      expect do
        create(:authentication, user: user, provider: authentication.provider, uid: authentication.uid)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'dependent: :destroy' do
    it 'userを削除するとauthenticationも削除される' do
      expect { user.destroy }.to change(Authentication, :count).by(-1)
    end
  end
end
