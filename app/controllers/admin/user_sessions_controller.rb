class Admin::UserSessionsController < AdminController
  skip_before_action :require_login
  layout 'admin_login'

  def new; end

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

  def destroy
    logout
    redirect_to admin_login_path
  end
end
