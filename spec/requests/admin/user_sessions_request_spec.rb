require 'rails_helper'

RSpec.describe 'Admin::UserSessions', type: :request do
  describe '#omniauth_callback' do
    subject { get '/admin/auth/google/callback', params: { code: 'dummy_code' } }

    let!(:user) { create(:user, :admin) }
    let(:uid) { '123456789' }
    let(:email) { user.email }
    let(:verified_email) { true }

    before do
      # NOTE: 外部認証への通信は行わず、sorceryが取得するユーザー情報のみ差し替える
      allow_any_instance_of(Admin::UserSessionsController).to receive(:sorcery_fetch_user_hash) do |controller|
        controller.instance_variable_set(
          :@user_hash,
          { uid: uid, user_info: { 'id' => uid, 'email' => email, 'verified_email' => verified_email } }
        )
      end
    end

    context '既に外部認証が紐付いている場合' do
      before { create(:authentication, user: user, provider: 'google', uid: uid) }

      it 'ログインできること' do
        expect { subject }.not_to change { [User.count, Authentication.count] }
        expect(response).to redirect_to admin_dashboards_path
      end
    end

    context '外部認証は未紐付けだが、検証済みのメールアドレスが既存ユーザーと一致する場合' do
      it '外部認証が紐付けられ、ログインできること' do
        expect { subject }.to change(Authentication, :count).by(1)
        expect(user.authentications.last).to have_attributes(provider: 'google', uid: uid)
        expect(response).to redirect_to admin_dashboards_path
      end
    end

    context 'メールアドレスが未検証の場合' do
      let(:verified_email) { false }

      it 'ログインできないこと' do
        expect { subject }.not_to change { [User.count, Authentication.count] }
        expect(response).to redirect_to admin_login_path
      end
    end

    context 'メールアドレスが一致する既存ユーザーがいない場合' do
      let(:email) { 'unknown@test.com' }

      it 'ユーザーが作成されず、ログインできないこと' do
        expect { subject }.not_to change { [User.count, Authentication.count] }
        expect(response).to redirect_to admin_login_path
      end
    end
  end
end
