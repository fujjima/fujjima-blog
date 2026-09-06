class AdminController < ApplicationController
  layout 'admin'
  before_action :require_login
  before_action :require_admin

  private

  # https://qiita.com/aiandrox/items/65317517954d8d44d957#require_login
  def not_authenticated
    redirect_to admin_login_path, alert: 'Please login first'
  end

  # NOTE: ログインできること = 管理画面を操作できること、ではないため、ログイン状態とは別にロールでも認可する
  def require_admin
    return if current_user&.admin?

    logout
    redirect_to admin_login_path, alert: '管理者権限がありません'
  end
end
