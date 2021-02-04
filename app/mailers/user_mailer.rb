class UserMailer < ApplicationMailer

  #account_activation.textか.htmlのテンプレートを使用してメールを送信する
  def account_activation(user)
    @user = user
    #user.emailへAccount activationのタイトルでメールを送るメソッド
    mail to: user.email, subject: "Account activation"
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
