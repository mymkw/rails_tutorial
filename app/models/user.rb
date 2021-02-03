class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! } 
  validates(:name, presence: true, length: { maximum: 50 } )
  VALID_EMAIL_REGIX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(:email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGIX },
                    uniqueness: { case_sensitive: false } )
  has_secure_password
  validates(:password, presence: true, length: { minimum: 6 } )

  #渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #トークン用にランダムな文字を返す rememberで使用
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #remember_tokenを作成、dbに保存 sessions_helperのremember(user)内で使用
  def remember
    #remember_tokenは一時的に作られるもので、remember_digestはdbに保存されるもの
    #sessionのcreateメソッド内のremember(user)メソッドで使用
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す session_helperのcurrent_userメソッドで使用
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end