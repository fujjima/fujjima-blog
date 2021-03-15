class Admin::UserSessionsController < ApplicationController
  layout false

  def new; end

  def create
    @user = login(params[:email], params[:password])
    if @user
      redirect_to admin_dashboards_path, notice: 'sucessed to login'
    else
      flash.now[:alert] = "failed to login"
      render :new
    end
  end

  def destroy
    logout
    redirect_to admin_login_path
  end
end
