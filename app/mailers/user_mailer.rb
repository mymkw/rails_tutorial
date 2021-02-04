class UserMailer < ApplicationMailer

  #account_activation.textか.htmlのテンプレートを使用してメールを送信する
  def account_activation(user)
    @user = user
    #user.emailへAccount activationのタイトルでメールを送るメソッド
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
