require 'rails_helper'

RSpec.describe 'Admin::Dashboards', type: :request do
  describe '#index' do
    subject { get admin_dashboards_path }

    before do
      # ref) https://qiita.com/dev-harry/items/0efc80619e314e9540f0
      allow_any_instance_of(Admin::DashboardsController)
        .to receive(:current_user)
        .and_return(user)
    end

    context 'generalロールのユーザーでログインしている場合' do
      let(:user) { create(:user, :admin, role: :general) }

      it 'ログイン画面にリダイレクトされること' do
        subject

        expect(response).to redirect_to admin_login_path
      end
    end
  end
end
