class Admin::ResetPasswordsController < AdminController
  skip_before_action :require_login
  layout 'admin_login'

  # パスワードリセット申請
  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email])
    user&.deliver_reset_password_instructions!

    redirect_to login_path, success: "Successed"
  end

  # パスワードリセット実施
  def edit

  end

  def update

  end

  private

  def user_params
    params.require(:user).permit()
  end
end
