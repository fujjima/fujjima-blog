class Admin::UserSessionsController < AdminController
  skip_before_action :require_login, :require_admin
  layout 'admin_login'

  def new; end

  def oauth
    # NOTE: 内部でsorceryが外部認証へのリダイレクトを行う
    login_at(params[:provider])
  end

  def create
    @user = login(params[:email], params[:password])
    # TODO: @userがいるか、メールの認証が完了しているかどうか
    if @user
      redirect_to admin_dashboards_path, notice: 'sucessed to login'
    else
      flash.now[:alert] = 'failed to login'
      render :new
    end
  end

  # NOTE: 外部認証からのコールバック用のエンドポイント。外部認証結果を元に、ユーザーのログイン処理を行う
  def omniauth_callback
    provider = auth_params[:provider]

    # NOTE: login_fromの仕様について(https://github.com/Sorcery/sorcery?tab=readme-ov-file#external)
    #       既に外部認証が紐付いているユーザーは、そのままログインさせる
    if (@user = login_from(provider))
      return redirect_to admin_dashboards_path, notice: "#{provider.titleize}アカウントでログインしました"
    end

    # NOTE: 外部認証経由でのユーザー新規作成は行わない。
    #       sorceryのcreate_fromはバリデーションを行わずにユーザーを保存するため、
    #       任意のアカウントで管理画面に入れるユーザーが作られてしまう
    if (@user = linkable_user).blank?
      return redirect_to admin_login_path, alert: "#{provider.titleize}アカウントでのログインは許可されていません"
    end

    @user.add_provider_to_user(provider.to_s, external_uid)

    # NOTE: protect from session fixation attack
    reset_session
    auto_login(@user)
    redirect_to admin_dashboards_path, notice: "#{provider.titleize}アカウントを紐付け、ログインしました"
  rescue StandardError
    redirect_to admin_login_path, alert: '外部認証でのログインに失敗しました'
  end

  def destroy
    logout
    redirect_to admin_login_path, notice: 'sucessed to logout'
  end

  private

  def auth_params
    params.permit(:code, :provider)
  end

  # NOTE: 外部認証から取得したユーザー情報。login_fromなどの実行時にsorceryが@user_hashへ格納する
  def external_user_info
    @user_hash&.dig(:user_info) || {}
  end

  def external_uid
    @user_hash&.dig(:uid).to_s
  end

  # NOTE: 外部認証のメールアドレスと一致する既存ユーザーを返す（該当がなければnil）。
  #       未検証のメールアドレスは第三者がなりすませるため、検証済みのもののみ受け付ける
  #       (verified_emailはGoogleのoauth2/v1/userinfoが返すキー)
  def linkable_user
    return if external_user_info['verified_email'] != true

    email = external_user_info['email']
    return if email.blank?

    User.find_by(email: email)
  end
end
