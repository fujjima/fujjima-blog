class Admin::UserSessionsController < ApplicationController
  layout false

  # ログイン画面表示
  def new
    render :new
  end

  # ログイン状態作成
  def create

  end

  # ログアウト
  def destroy

  end
end
