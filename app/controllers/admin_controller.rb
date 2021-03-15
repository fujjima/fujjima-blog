class AdminController < ApplicationController
  layout 'admin'
  before_action :require_login

  private

  # https://qiita.com/aiandrox/items/65317517954d8d44d957#require_login
  def not_authenticated
    redirect_to admin_login_path, alert: 'Please login first'
  end
end
