class Micropost < ApplicationRecord
  #user.micropost.user_idとuser.idが紐づいている
  belongs_to :user
  #デフォルトの順序を指定するメソッド Procやlambdaも使用
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size

  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
