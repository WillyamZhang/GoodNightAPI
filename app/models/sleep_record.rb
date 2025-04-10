class SleepRecord < ApplicationRecord
  belongs_to :user

  # validate when clock_out value is available
  validate :validate_clocked_out, if: -> { clock_out.present? }

  private

  def self.all_record(user_id)
    where(user_id: user_id).order("created_at")
  end

  def self.active_for(user_id)
    find_by(user_id: user_id, clock_out: nil)
  end

  def validate_clocked_out
    if clock_out < clock_in
      errors.add(:clock_out, "Clocked Out datetime must be greater than Clocked In")
    end
  end
end
