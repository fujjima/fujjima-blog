class Admin::ResetPasswordsController < AdminController
  skip_before_action :require_login
  layout 'admin_login'

  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:email])
    # TODO: userがいない場合にエラーを出す
    user&.deliver_reset_password_instructions!

    redirect_to admin_login_path, notice: "Successed"
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    return not_authenticated if @user.blank?
  end

  def update
    @user = User.load_from_reset_password_token(params[:id])
    return not_authenticated if @user.blank?

    # TODO: back側でも一応passwordと再入力の項目が一致しているかを確認する。
    if @user.change_password(params[:password])
      redirect_to admin_login_path, notice: "sucessed"
    else
      flash.now[:danger] = "failed"
      render :edit
    end
  end
end
