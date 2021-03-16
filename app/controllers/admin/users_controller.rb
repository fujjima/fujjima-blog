class Admin::UsersController < AdminController
  # edit, updateの時は必要かも（adminログイン後、admin情報を変更したい時など）
  skip_before_action :require_login
  layout 'admin_login'

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)
    # TODO: メールがこなかった場合の対処
    if @user.save
      UserMailer.activation_needed_email(@user).deliver_now
      redirect_to admin_login_path, notice: 'please verify your email address'
    else
      flash.now[:alert] = "failed to create user"
      render :new
    end
  end

  def update; end

  def destroy; end

  def activate
    # TODO: メール認証が成功したら権限を管理者に変更してログイン可能とする
    binding.pry
    if @user = User.load_from_activation_token(params[:id])
      @user.activate!
      redirect_to admin_login_path, notice: 'User was successfully activated!'
    else
      not_authenticated
    end
    
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
