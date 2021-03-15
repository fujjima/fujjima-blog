class Admin::UsersController < ApplicationController

  # サインアップ画面表示
  def new

  end

  # 管理者情報更新画面表示
  def edit

  end

  def create
    @user = User.new(user_params)
    if @user.save
    else
    end
  end

  # 管理者情報更新（パスワード更新など）
  def update

  end

  def destroy

  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
