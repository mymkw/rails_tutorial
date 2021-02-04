class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  #有効期限が切れてないかの対応

  def new
    #メールアドレスを入力する画面
  end

  def create
    #newから受け取ったアドレスのユーザにトークンとダイジェストを付与、パスワード再設定用メールを送信。
    @user = User.find_by(email: params[:password_reset][:email])
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not fount"
      render 'new'
    end
  end

  def edit
    #送信したメールのリンク先。パスワード再設定用画面へ。URLにはトークンとアドレスも付いている。
  end

  def update
    #editから受け取ったメールアドレスを元にパスワードを変更する
    if params[:user][:password].empty? #パスワードが空のとき
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params) #新しいパスワードが正しいとき
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit' #無効なパスワードだったとき
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    #beforeフィルタ

    #メールのeditのリンクからアドレスを取得するとき　params[:email]で取得が出来る。(params[:user][:email]ではなく。)
    #なのでupdateでも同じ取得方法を実現するためにedit.htmlではparams[:email]で取得できるように書いている
    def get_user
      @user = User.find_by(email: params[:email])
    end

    #正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired? #->Userモデル
        flash[:danger] = "Password reset haz expired."
        redirect_to new_password_reset_url
      end
    end
end
