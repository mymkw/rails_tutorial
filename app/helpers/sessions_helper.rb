module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  #ユーザーのセッションを永続的にする sessions_controllerのcreate内で使用
  def remember(user)
    user.remember #ユーザにトークンを付与、dbにトークンを保存
    cookies.permanent.signed[:user_id] = user.id #cookiesのuser_idに現在のユーザーを署名付きで保存
    cookies.permanent[:remember_token] = user.remember_token #cookiesのremember_tokenに現在のユーザのトークンを保存(後でdbの値と比較するため)
  end

  # 現在ログインしているユーザーを返す (いる場合)
  # 記憶トークンcookieに対応するユーザーを返す
  #logged_in?で使用
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    #ログインされていない場合
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token]) #cookieのremember_tokenが一致すれば
        log_in user #セッションに代入するだけ(上のメソッドのこと)
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  #永続的セッションを破棄する(クッキーを削除する)
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
