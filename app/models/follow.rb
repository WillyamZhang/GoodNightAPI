class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followed, class_name: 'User'

  #  check the combination of user_id and followed_id must be unique.
  validates :user_id, uniqueness: { scope: :followed_id, message: "already follows this user" }
  validate :cannot_follow_self

  def cannot_follow_self
    errors.add(:followed_id, "can't follow your self") if user_id == followed_id
  end
end
