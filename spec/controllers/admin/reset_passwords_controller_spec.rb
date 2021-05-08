require 'rails_helper'

RSpec.describe Admin::ResetPasswordsController, type: :controller do
  let(:user){ create :user, :admin }
  let(:password_reset_user){ create :user, :admin, reset_password_token: SecureRandom.hex(20) }
  let(:mail){ ActionMailer::Base.deliveries }
  # before do
  # end
  after(:all) do
    ActionMailer::Base.deliveries.clear
  end

  describe '#GET new' do
    # https://skullware.net/blog/archives/wp-qiita/ad7a8ade9e7a99fb4384
    it 'show reset password form' do
      get :new
      expect(response).to have_http_status 200
    end
  end

  describe '#POST create' do
    it 'send email and redirect login url' do
      user.save
      # ユーザー作成時のメールをリセットしておく
      ActionMailer::Base.deliveries.clear

      # XXX: :createだと送信できて、admin_reset_passwords_pathでの指定だとrouteが検出されない
      post :create, params: { email: user.email }

      expect(response).to have_http_status 302
      expect(mail.count).to eq(1)
      expect(mail.last.to.last).to eq('test@test.com')
      expect(response).to redirect_to "/admin/login"
    end
  end

  describe '#GET edit' do
    it 'valid user' do
      password_reset_user.save
      get :edit, params: { id: password_reset_user.reset_password_token }
      expect(response).to have_http_status 200
      expect(controller.instance_variable_get('@user')).to eq password_reset_user
    end

    it 'invalid user' do
      password_reset_user.save
      get :edit, params: { id: 'unknowntoken' }
      expect(flash[:alert]).to be_present
      expect(response).to redirect_to "/admin/login"
    end
  end

  describe '#PUT update' do
    
    it 'sucess to reset password' do
      password_reset_user.save
      put :update, params: { id: password_reset_user.reset_password_token }
      expect(response).to have_http_status 302
      expect(flash[:notice]).to be_present
      expect(response).to redirect_to "/admin/login"
    end
    it 'fail to reset password' do
      password_reset_user.save
      put :update, params: { id: password_reset_user.reset_password_token, password: 'unknown' }
      expect(flash[:danger]).to be_present
    end
  end
end
