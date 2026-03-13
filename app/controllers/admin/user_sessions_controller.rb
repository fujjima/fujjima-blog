class Admin::UserSessionsController < AdminController
  skip_before_action :require_login
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
    if (@user = login_from(provider))
      redirect_to admin_dashboards_path, notice: "#{provider.titleize}アカウントでログインしました"
    else
      begin
        @user = create_from(provider)

        # NOTE: protect from session fixation attack
        reset_session
        auto_login(@user)
        redirect_to admin_dashboards_path, notice: "#{provider.titleize}アカウントを追加し、ログインしました。"
      rescue StandardError
        redirect_to root_path, alert: "#{provider.titleize}アカウントでのログインに失敗しました"
      end
    end
  end

  def destroy
    logout
    redirect_to admin_login_path, notice: 'sucessed to logout'
  end

  private

  def auth_params
    params.permit(:code, :provider)
  end
end
