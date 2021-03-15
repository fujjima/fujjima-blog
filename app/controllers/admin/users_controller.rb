class Admin::UsersController < ApplicationController
  layout false

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    # TODO: メールがこなかった場合の対処
    if @user.save
      # TODO: メール認証用のメール飛ばす
      redirect_to admin_login_path, notice: 'please verify your email address'
    else
      flash.now[:alert] = "failed to create user"
      render :new
    end
  end

  def update; end

  def destroy; end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
