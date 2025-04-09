class SleepRecord < ApplicationRecord
  belongs_to :user


  private

  def self.all_record(user_id)
    where(user_id: user_id).order("created_at")
  end
end
